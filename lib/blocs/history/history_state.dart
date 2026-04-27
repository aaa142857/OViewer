import 'package:equatable/equatable.dart';
import '../../core/storage/database.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<HistoryEntry> entries;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryEntry>? entries,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}
