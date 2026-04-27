import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/gallery_repository.dart';
import 'thumbnail_preview_event.dart';
import 'thumbnail_preview_state.dart';

class ThumbnailPreviewBloc
    extends Bloc<ThumbnailPreviewEvent, ThumbnailPreviewState> {
  final GalleryRepository _galleryRepo;

  ThumbnailPreviewBloc(this._galleryRepo)
      : super(const ThumbnailPreviewState()) {
    on<LoadThumbnailPreview>(_onLoad);
    on<LoadMoreThumbnails>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadThumbnailPreview event,
    Emitter<ThumbnailPreviewState> emit,
  ) async {
    emit(state.copyWith(
      status: ThumbnailPreviewStatus.loading,
      gid: event.gid,
      token: event.token,
    ));

    try {
      final result = await _galleryRepo.fetchThumbnails(
        event.gid,
        event.token,
      );
      emit(state.copyWith(
        status: ThumbnailPreviewStatus.loaded,
        thumbnails: result.thumbnails,
        totalPages: result.totalPages,
        currentPage: 0,
        hasReachedEnd: result.totalPages <= 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ThumbnailPreviewStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreThumbnails event,
    Emitter<ThumbnailPreviewState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedEnd) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _galleryRepo.fetchThumbnails(
        state.gid,
        state.token,
        page: nextPage,
      );
      final allThumbnails = [...state.thumbnails, ...result.thumbnails];
      emit(state.copyWith(
        thumbnails: allThumbnails,
        currentPage: nextPage,
        isLoadingMore: false,
        hasReachedEnd: nextPage >= state.totalPages - 1,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
