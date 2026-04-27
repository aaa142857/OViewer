import 'package:equatable/equatable.dart';

class SearchFilter extends Equatable {
  final String? keyword;
  final List<String> categories;
  final int? minRating;
  final int? minPages;
  final int? maxPages;
  final bool searchGalleryName;
  final bool searchGalleryTags;
  final bool searchGalleryDesc;
  final bool searchLowPowerTags;

  const SearchFilter({
    this.keyword,
    this.categories = const [],
    this.minRating,
    this.minPages,
    this.maxPages,
    this.searchGalleryName = true,
    this.searchGalleryTags = true,
    this.searchGalleryDesc = false,
    this.searchLowPowerTags = false,
  });

  SearchFilter copyWith({
    String? keyword,
    List<String>? categories,
    int? minRating,
    int? minPages,
    int? maxPages,
    bool? searchGalleryName,
    bool? searchGalleryTags,
    bool? searchGalleryDesc,
    bool? searchLowPowerTags,
  }) {
    return SearchFilter(
      keyword: keyword ?? this.keyword,
      categories: categories ?? this.categories,
      minRating: minRating ?? this.minRating,
      minPages: minPages ?? this.minPages,
      maxPages: maxPages ?? this.maxPages,
      searchGalleryName: searchGalleryName ?? this.searchGalleryName,
      searchGalleryTags: searchGalleryTags ?? this.searchGalleryTags,
      searchGalleryDesc: searchGalleryDesc ?? this.searchGalleryDesc,
      searchLowPowerTags: searchLowPowerTags ?? this.searchLowPowerTags,
    );
  }

  @override
  List<Object?> get props => [
        keyword,
        categories,
        minRating,
        minPages,
        maxPages,
        searchGalleryName,
        searchGalleryTags,
      ];
}
