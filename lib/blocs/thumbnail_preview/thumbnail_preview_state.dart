import 'package:equatable/equatable.dart';
import '../../core/parser/gallery_detail_parser.dart';

enum ThumbnailPreviewStatus { initial, loading, loaded, error }

class ThumbnailPreviewState extends Equatable {
  final ThumbnailPreviewStatus status;
  final List<ThumbnailInfo> thumbnails;
  final int gid;
  final String token;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? errorMessage;

  const ThumbnailPreviewState({
    this.status = ThumbnailPreviewStatus.initial,
    this.thumbnails = const [],
    this.gid = 0,
    this.token = '',
    this.currentPage = 0,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.errorMessage,
  });

  ThumbnailPreviewState copyWith({
    ThumbnailPreviewStatus? status,
    List<ThumbnailInfo>? thumbnails,
    int? gid,
    String? token,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? errorMessage,
  }) {
    return ThumbnailPreviewState(
      status: status ?? this.status,
      thumbnails: thumbnails ?? this.thumbnails,
      gid: gid ?? this.gid,
      token: token ?? this.token,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        thumbnails,
        gid,
        token,
        currentPage,
        totalPages,
        isLoadingMore,
        hasReachedEnd,
        errorMessage,
      ];
}
