import 'package:equatable/equatable.dart';
import '../../models/gallery_image.dart';
import '../../core/parser/gallery_detail_parser.dart';

enum ReaderStatus { initial, loading, ready, error }

class ReaderState extends Equatable {
  final ReaderStatus status;
  final int gid;
  final String token;
  final int currentPage;
  final int totalPages;
  final Map<int, GalleryImage> loadedImages;
  final List<ThumbnailInfo> thumbnails;
  final bool showUI;
  final int readingMode; // 0=LR, 1=RL, 2=vertical
  final String? errorMessage;

  const ReaderState({
    this.status = ReaderStatus.initial,
    this.gid = 0,
    this.token = '',
    this.currentPage = 0,
    this.totalPages = 0,
    this.loadedImages = const {},
    this.thumbnails = const [],
    this.showUI = false,
    this.readingMode = 0,
    this.errorMessage,
  });

  GalleryImage? get currentImage => loadedImages[currentPage];

  ReaderState copyWith({
    ReaderStatus? status,
    int? gid,
    String? token,
    int? currentPage,
    int? totalPages,
    Map<int, GalleryImage>? loadedImages,
    List<ThumbnailInfo>? thumbnails,
    bool? showUI,
    int? readingMode,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      gid: gid ?? this.gid,
      token: token ?? this.token,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      loadedImages: loadedImages ?? this.loadedImages,
      thumbnails: thumbnails ?? this.thumbnails,
      showUI: showUI ?? this.showUI,
      readingMode: readingMode ?? this.readingMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        gid,
        currentPage,
        totalPages,
        loadedImages.length,
        showUI,
        readingMode,
        errorMessage,
      ];
}
