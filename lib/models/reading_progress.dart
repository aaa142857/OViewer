import 'package:equatable/equatable.dart';

class ReadingProgress extends Equatable {
  final int gid;
  final int lastReadPage;
  final int totalPages;
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.gid,
    required this.lastReadPage,
    required this.totalPages,
    required this.lastReadAt,
  });

  double get percentage =>
      totalPages > 0 ? (lastReadPage + 1) / totalPages : 0.0;

  @override
  List<Object?> get props => [gid, lastReadPage, totalPages];
}
