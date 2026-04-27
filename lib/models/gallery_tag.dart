import 'package:equatable/equatable.dart';

class GalleryTag extends Equatable {
  final String namespace;
  final String key;
  final String? translation;
  final bool isUpvoted;
  final bool isDownvoted;

  const GalleryTag({
    required this.namespace,
    required this.key,
    this.translation,
    this.isUpvoted = false,
    this.isDownvoted = false,
  });

  String get displayName => translation ?? key;

  @override
  List<Object?> get props => [namespace, key];
}
