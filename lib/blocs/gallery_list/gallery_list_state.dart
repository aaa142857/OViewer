import 'package:equatable/equatable.dart';
import '../../models/gallery_preview.dart';
import 'gallery_list_event.dart';

enum GalleryListStatus { initial, loading, loaded, error }

const _sentinel = Object();

class GalleryListState extends Equatable {
  final GalleryListStatus status;
  final List<GalleryPreview> galleries;
  final int currentPage;
  final int totalPages;
  final GalleryTab currentTab;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? nextPageUrl;

  const GalleryListState({
    this.status = GalleryListStatus.initial,
    this.galleries = const [],
    this.currentPage = 0,
    this.totalPages = 1,
    this.currentTab = GalleryTab.latest,
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.nextPageUrl,
  });

  GalleryListState copyWith({
    GalleryListStatus? status,
    List<GalleryPreview>? galleries,
    int? currentPage,
    int? totalPages,
    GalleryTab? currentTab,
    Object? errorMessage = _sentinel,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    Object? nextPageUrl = _sentinel,
  }) {
    return GalleryListState(
      status: status ?? this.status,
      galleries: galleries ?? this.galleries,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentTab: currentTab ?? this.currentTab,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      nextPageUrl: nextPageUrl == _sentinel
          ? this.nextPageUrl
          : nextPageUrl as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        galleries,
        currentPage,
        totalPages,
        currentTab,
        errorMessage,
        isLoadingMore,
        hasReachedEnd,
        nextPageUrl,
      ];
}
