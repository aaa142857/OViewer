import 'package:equatable/equatable.dart';
import '../../models/gallery_preview.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<GalleryPreview> favorites;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.currentPage = 0,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<GalleryPreview>? favorites,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, favorites, currentPage, isLoadingMore];
}
