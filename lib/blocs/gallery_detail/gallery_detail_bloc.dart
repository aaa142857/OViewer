import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/gallery_repository.dart';
import '../../repositories/favorites_repository.dart';
import '../../models/gallery_detail.dart';
import '../../models/gallery_preview.dart';
import 'gallery_detail_event.dart';
import 'gallery_detail_state.dart';

class GalleryDetailBloc
    extends Bloc<GalleryDetailEvent, GalleryDetailState> {
  final GalleryRepository _repository;
  final FavoritesRepository _favoritesRepo;

  GalleryDetailBloc(this._repository, this._favoritesRepo)
      : super(const GalleryDetailState()) {
    on<FetchGalleryDetail>(_onFetch);
    on<ToggleFavorite>(_onToggleFavorite);
    on<RateGallery>(_onRate);
    on<PostComment>(_onPostComment);
    on<VoteComment>(_onVoteComment);
  }

  Future<void> _onFetch(
    FetchGalleryDetail event,
    Emitter<GalleryDetailState> emit,
  ) async {
    emit(state.copyWith(status: GalleryDetailStatus.loading));
    try {
      final detail =
          await _repository.fetchGalleryDetail(event.gid, event.token);
      emit(state.copyWith(
        status: GalleryDetailStatus.loaded,
        detail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GalleryDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<GalleryDetailState> emit,
  ) async {
    if (state.detail == null) return;
    final detail = state.detail!;
    final wasFavorited = detail.isFavorited;

    // Optimistic UI update
    final updatedDetail = GalleryDetail(
      gid: detail.gid,
      token: detail.token,
      title: detail.title,
      titleJpn: detail.titleJpn,
      thumbUrl: detail.thumbUrl,
      category: detail.category,
      uploader: detail.uploader,
      postedAt: detail.postedAt,
      parent: detail.parent,
      visible: detail.visible,
      language: detail.language,
      fileCount: detail.fileCount,
      fileSize: detail.fileSize,
      rating: detail.rating,
      ratingCount: detail.ratingCount,
      favoriteCount: detail.favoriteCount,
      favoritedSlot: wasFavorited ? null : (event.slot ?? 0),
      tags: detail.tags,
      comments: detail.comments,
      thumbnails: detail.thumbnails,
      archiveUrl: detail.archiveUrl,
    );
    emit(state.copyWith(detail: updatedDetail));

    try {
      if (wasFavorited) {
        await _favoritesRepo.removeCloudFavorite(event.gid, event.token);
      } else {
        final slot = event.slot ?? 0;
        await _favoritesRepo.addCloudFavorite(
          event.gid,
          event.token,
          slot: slot,
          preview: GalleryPreview(
            gid: detail.gid,
            token: detail.token,
            title: detail.title,
            thumbUrl: detail.thumbUrl,
            category: detail.category,
            rating: detail.rating,
            uploader: detail.uploader,
            fileCount: detail.fileCount,
            postedAt: detail.postedAt,
          ),
        );
      }
    } catch (_) {
      // Revert on failure
      emit(state.copyWith(detail: detail));
    }
  }

  Future<void> _onRate(
    RateGallery event,
    Emitter<GalleryDetailState> emit,
  ) async {
    try {
      final result = await _repository.rateGallery(
          event.gid, event.token, event.rating);
      // Update the detail with new rating
      if (state.detail != null) {
        final updated = GalleryDetail(
          gid: state.detail!.gid,
          token: state.detail!.token,
          title: state.detail!.title,
          titleJpn: state.detail!.titleJpn,
          thumbUrl: state.detail!.thumbUrl,
          category: state.detail!.category,
          uploader: state.detail!.uploader,
          postedAt: state.detail!.postedAt,
          parent: state.detail!.parent,
          visible: state.detail!.visible,
          language: state.detail!.language,
          fileCount: state.detail!.fileCount,
          fileSize: state.detail!.fileSize,
          rating: result.averageRating,
          ratingCount: result.ratingCount,
          favoriteCount: state.detail!.favoriteCount,
          favoritedSlot: state.detail!.favoritedSlot,
          tags: state.detail!.tags,
          comments: state.detail!.comments,
          thumbnails: state.detail!.thumbnails,
          archiveUrl: state.detail!.archiveUrl,
        );
        emit(state.copyWith(detail: updated));
      }
    } catch (_) {
      // Rating failed silently
    }
  }

  Future<void> _onPostComment(
    PostComment event,
    Emitter<GalleryDetailState> emit,
  ) async {
    try {
      await _repository.postComment(event.gid, event.token, event.comment);
      // Refresh detail to show new comment
      add(FetchGalleryDetail(gid: event.gid, token: event.token));
    } catch (_) {
      // Comment post failed
    }
  }

  Future<void> _onVoteComment(
    VoteComment event,
    Emitter<GalleryDetailState> emit,
  ) async {
    try {
      await _repository.voteComment(
          event.gid, event.token, event.commentId, event.isUpvote);
    } catch (_) {
      // Vote failed silently
    }
  }
}
