/// Utility for parsing E-Hentai / ExHentai gallery URLs.
class EhUrlParser {
  static final _galleryUrlRegex = RegExp(
    r'https?://(?:e-hentai|exhentai)\.org/g/(\d+)/([a-f0-9]+)',
  );

  /// Try to extract (gid, token) from a gallery URL.
  /// Returns null if the string is not a valid gallery URL.
  /// Access as `result.$1` (gid) and `result.$2` (token).
  static (int, String)? parseGalleryUrl(String text) {
    final match = _galleryUrlRegex.firstMatch(text.trim());
    if (match == null) return null;
    return (int.parse(match.group(1)!), match.group(2)!);
  }
}
