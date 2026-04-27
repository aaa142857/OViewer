import 'gallery_list_parser.dart';
import '../../models/gallery_preview.dart';

class SearchParser {
  /// Parse search results - same format as gallery list
  static List<GalleryPreview> parseResults(String htmlString) {
    return GalleryListParser.parse(htmlString);
  }

  /// Parse total result count from search page
  static int parseResultCount(String htmlString) {
    final match =
        RegExp(r'Showing\s+[\d,]+-[\d,]+\s+of\s+([\d,]+)')
            .firstMatch(htmlString);
    if (match != null) {
      return int.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
    }
    return 0;
  }

  /// Parse page count from search results
  static int parsePageCount(String htmlString) {
    return GalleryListParser.parsePageCount(htmlString);
  }

  /// Parse the next page URL from search results
  static String? parseNextPageUrl(String htmlString) {
    return GalleryListParser.parseNextPageUrl(htmlString);
  }
}
