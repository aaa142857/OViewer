import 'package:html/parser.dart' as html_parser;

class MyTagsParser {
  /// Parse hidden tags from the E-Hentai mytags page HTML.
  /// Returns a list of tag names (e.g., "other:ai generated") that are
  /// marked as hidden by the user.
  static List<String> parseHiddenTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    final hiddenTags = <String>[];

    // Each user tag has id="usertag_N"; usertag_0 is the "add" form row
    final userTagDivs = document.querySelectorAll('div[id^="usertag_"]');
    for (final div in userTagDivs) {
      final id = div.attributes['id'] ?? '';
      if (id == 'usertag_0') continue;

      // Check if the "hide" checkbox is checked
      final hideInput = div.querySelector('input[id^="taghide_"]');
      if (hideInput == null) continue;
      final isHidden = hideInput.attributes.containsKey('checked') ||
          hideInput.attributes['checked'] == 'checked';
      if (!isHidden) continue;

      // Extract tag name from the div.gt[title] element
      final tagDiv = div.querySelector('div.gt[title]');
      if (tagDiv == null) continue;
      final tagName = tagDiv.attributes['title']?.trim();
      if (tagName != null && tagName.isNotEmpty) {
        hiddenTags.add(tagName);
      }
    }

    return hiddenTags;
  }
}
