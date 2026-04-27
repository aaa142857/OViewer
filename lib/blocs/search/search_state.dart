import 'package:equatable/equatable.dart';
import '../../models/gallery_preview.dart';
import '../../models/search_filter.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final SearchFilter filter;
  final List<GalleryPreview> results;
  final List<String> searchHistory;
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? errorMessage;
  final String? nextPageUrl;

  const SearchState({
    this.status = SearchStatus.initial,
    this.filter = const SearchFilter(),
    this.results = const [],
    this.searchHistory = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalResults = 0,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.errorMessage,
    this.nextPageUrl,
  });

  SearchState copyWith({
    SearchStatus? status,
    SearchFilter? filter,
    List<GalleryPreview>? results,
    List<String>? searchHistory,
    int? currentPage,
    int? totalPages,
    int? totalResults,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return SearchState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      results: results ?? this.results,
      searchHistory: searchHistory ?? this.searchHistory,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [
        status,
        filter,
        results,
        searchHistory,
        currentPage,
        isLoadingMore,
        hasReachedEnd,
        nextPageUrl,
      ];
}
