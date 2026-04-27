import 'package:equatable/equatable.dart';

class GalleryPreview extends Equatable {
  final int gid;
  final String token;
  final String title;
  final String thumbUrl;
  final String category;
  final double rating;
  final String uploader;
  final int fileCount;
  final int fileSize;
  final String? language;
  final DateTime postedAt;
  final List<String> tags;
  final bool isFavorited;

  const GalleryPreview({
    required this.gid,
    required this.token,
    required this.title,
    required this.thumbUrl,
    required this.category,
    required this.rating,
    required this.uploader,
    required this.fileCount,
    this.fileSize = 0,
    this.language,
    required this.postedAt,
    this.tags = const [],
    this.isFavorited = false,
  });

  GalleryPreview copyWith({bool? isFavorited}) =>
      GalleryPreview(
        gid: gid,
        token: token,
        title: title,
        thumbUrl: thumbUrl,
        category: category,
        rating: rating,
        uploader: uploader,
        fileCount: fileCount,
        fileSize: fileSize,
        language: language,
        postedAt: postedAt,
        tags: tags,
        isFavorited: isFavorited ?? this.isFavorited,
      );

  @override
  List<Object?> get props => [gid, token, isFavorited];
}
