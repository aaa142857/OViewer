import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/download_repository.dart';
import '../../repositories/gallery_repository.dart';
import '../../models/download_task.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository _downloadRepo;
  final GalleryRepository _galleryRepo;
  final Set<int> _pauseRequested = {};

  DownloadBloc(this._downloadRepo, this._galleryRepo)
      : super(const DownloadState()) {
    on<LoadDownloads>(_onLoad);
    on<StartDownload>(_onStart);
    on<PauseDownload>(_onPause);
    on<ResumeDownload>(_onResume);
    on<DeleteDownload>(_onDelete);
  }

  Future<void> _onLoad(
    LoadDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    emit(state.copyWith(status: DownloadListStatus.loading));
    try {
      final tasks = await _downloadRepo.getAllDownloads();
      emit(state.copyWith(
        status: DownloadListStatus.loaded,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DownloadListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStart(
    StartDownload event,
    Emitter<DownloadState> emit,
  ) async {
    // Create task in DB
    await _downloadRepo.createDownload(
      gid: event.gid,
      token: event.token,
      title: event.title,
      thumbUrl: event.thumbUrl,
      totalPages: event.totalPages,
    );

    // Mark as downloading
    await _downloadRepo.updateStatus(event.gid, DownloadStatus.downloading);
    final active = Set<int>.from(state.activeDownloads)..add(event.gid);
    emit(state.copyWith(activeDownloads: active));

    // Refresh list
    add(LoadDownloads());

    // Start downloading images
    _downloadGalleryImages(event.gid, event.token, event.totalPages);
  }

  Future<void> _downloadGalleryImages(
      int gid, String token, int totalPages) async {
    try {
      // Fetch all thumbnail page tokens
      final firstResult =
          await _galleryRepo.fetchThumbnails(gid, token);

      // Fetch remaining pages if needed
      final allThumbs = List.of(firstResult.thumbnails);
      final numPages = firstResult.totalPages;
      if (numPages > 1 && allThumbs.length < totalPages) {
        for (var p = 1; p < numPages; p++) {
          final more = await _galleryRepo.fetchThumbnails(gid, token, page: p);
          allThumbs.addAll(more.thumbnails);
        }
      }
      allThumbs.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));

      // Download each image sequentially
      var downloaded = 0;
      for (final thumb in allThumbs) {
        // Check for pause
        if (_pauseRequested.contains(gid)) {
          _pauseRequested.remove(gid);
          await _downloadRepo.updateStatus(gid, DownloadStatus.paused);
          add(LoadDownloads());
          return;
        }

        final success = await _downloadRepo.downloadImage(
            gid, thumb.pageToken, thumb.pageIndex);
        if (success) {
          downloaded++;
          await _downloadRepo.updateProgress(gid, downloaded);
        }
      }

      // Mark complete
      await _downloadRepo.updateStatus(gid, DownloadStatus.completed);
      add(LoadDownloads());
    } catch (e) {
      await _downloadRepo.updateStatus(gid, DownloadStatus.failed);
      add(LoadDownloads());
    }
  }

  Future<void> _onPause(
    PauseDownload event,
    Emitter<DownloadState> emit,
  ) async {
    _pauseRequested.add(event.gid);
  }

  Future<void> _onResume(
    ResumeDownload event,
    Emitter<DownloadState> emit,
  ) async {
    _pauseRequested.remove(event.gid);
    await _downloadRepo.updateStatus(event.gid, DownloadStatus.downloading);
    final active = Set<int>.from(state.activeDownloads)..add(event.gid);
    emit(state.copyWith(activeDownloads: active));

    // Get current task to know totalPages
    final tasks = await _downloadRepo.getAllDownloads();
    final task = tasks.firstWhere((t) => t.gid == event.gid);
    _downloadGalleryImages(event.gid, event.token, task.totalPages);
    add(LoadDownloads());
  }

  Future<void> _onDelete(
    DeleteDownload event,
    Emitter<DownloadState> emit,
  ) async {
    _pauseRequested.add(event.gid); // stop if downloading
    await _downloadRepo.deleteDownload(event.gid);
    final active = Set<int>.from(state.activeDownloads)..remove(event.gid);
    emit(state.copyWith(activeDownloads: active));
    add(LoadDownloads());
  }
}
