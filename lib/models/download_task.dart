import 'package:equatable/equatable.dart';

enum DownloadStatus { pending, downloading, paused, completed, failed }

class DownloadTask extends Equatable {
  final int gid;
  final String token;
  final String title;
  final String thumbUrl;
  final int totalPages;
  final int downloadedPages;
  final DownloadStatus status;
  final DateTime createdAt;

  const DownloadTask({
    required this.gid,
    required this.token,
    required this.title,
    required this.thumbUrl,
    required this.totalPages,
    this.downloadedPages = 0,
    this.status = DownloadStatus.pending,
    required this.createdAt,
  });

  double get progress =>
      totalPages > 0 ? downloadedPages / totalPages : 0.0;

  bool get isComplete => status == DownloadStatus.completed;

  @override
  List<Object?> get props => [gid, token, status, downloadedPages];
}
