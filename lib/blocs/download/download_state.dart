import 'package:equatable/equatable.dart';
import '../../models/download_task.dart';

enum DownloadListStatus { initial, loading, loaded, error }

class DownloadState extends Equatable {
  final DownloadListStatus status;
  final List<DownloadTask> tasks;
  final Set<int> activeDownloads; // gids currently downloading
  final String? errorMessage;

  const DownloadState({
    this.status = DownloadListStatus.initial,
    this.tasks = const [],
    this.activeDownloads = const {},
    this.errorMessage,
  });

  DownloadState copyWith({
    DownloadListStatus? status,
    List<DownloadTask>? tasks,
    Set<int>? activeDownloads,
    String? errorMessage,
  }) {
    return DownloadState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, activeDownloads, errorMessage];
}
