import 'package:equatable/equatable.dart';

class GalleryComment extends Equatable {
  final int id;
  final String author;
  final DateTime postedAt;
  final String content;
  final int score;
  final bool isUploader;
  final bool isVotedUp;
  final bool isVotedDown;

  const GalleryComment({
    required this.id,
    required this.author,
    required this.postedAt,
    required this.content,
    this.score = 0,
    this.isUploader = false,
    this.isVotedUp = false,
    this.isVotedDown = false,
  });

  @override
  List<Object?> get props => [id];
}
