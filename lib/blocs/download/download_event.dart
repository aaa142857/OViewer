import 'package:equatable/equatable.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class LoadDownloads extends DownloadEvent {}

class StartDownload extends DownloadEvent {
  final int gid;
  final String token;
  final String title;
  final String thumbUrl;
  final int totalPages;

  const StartDownload({
    required this.gid,
    required this.token,
    required this.title,
    required this.thumbUrl,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [gid];
}

class PauseDownload extends DownloadEvent {
  final int gid;
  const PauseDownload(this.gid);
  @override
  List<Object?> get props => [gid];
}

class ResumeDownload extends DownloadEvent {
  final int gid;
  final String token;
  const ResumeDownload({required this.gid, required this.token});
  @override
  List<Object?> get props => [gid];
}

class DeleteDownload extends DownloadEvent {
  final int gid;
  const DeleteDownload(this.gid);
  @override
  List<Object?> get props => [gid];
}
