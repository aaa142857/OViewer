import 'package:equatable/equatable.dart';

abstract class ThumbnailPreviewEvent extends Equatable {
  const ThumbnailPreviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadThumbnailPreview extends ThumbnailPreviewEvent {
  final int gid;
  final String token;
  const LoadThumbnailPreview({required this.gid, required this.token});
  @override
  List<Object?> get props => [gid, token];
}

class LoadMoreThumbnails extends ThumbnailPreviewEvent {
  const LoadMoreThumbnails();
}
