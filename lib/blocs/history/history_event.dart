import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {}

class DeleteHistoryEntry extends HistoryEvent {
  final int gid;
  const DeleteHistoryEntry(this.gid);
  @override
  List<Object?> get props => [gid];
}

class ClearAllHistory extends HistoryEvent {}
