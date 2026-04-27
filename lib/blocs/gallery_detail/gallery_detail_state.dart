import 'package:equatable/equatable.dart';
import '../../models/gallery_detail.dart';

enum GalleryDetailStatus { initial, loading, loaded, error }

class GalleryDetailState extends Equatable {
  final GalleryDetailStatus status;
  final GalleryDetail? detail;
  final String? errorMessage;

  const GalleryDetailState({
    this.status = GalleryDetailStatus.initial,
    this.detail,
    this.errorMessage,
  });

  GalleryDetailState copyWith({
    GalleryDetailStatus? status,
    GalleryDetail? detail,
    String? errorMessage,
  }) {
    return GalleryDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detail, errorMessage];
}
