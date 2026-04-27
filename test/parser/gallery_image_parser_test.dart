import 'package:flutter_test/flutter_test.dart';
import 'package:oviewer/core/parser/gallery_image_parser.dart';

void main() {
  group('GalleryImageParser', () {
    test('parseShowKey extracts showkey from JavaScript', () {
      const html = '''
      <script>var showkey = "abc123def456";</script>
      ''';
      expect(GalleryImageParser.parseShowKey(html), 'abc123def456');
    });

    test('parseShowKey returns null when not found', () {
      expect(GalleryImageParser.parseShowKey('<html></html>'), isNull);
    });

    test('parseNextPageToken extracts token from next link', () {
      const html = '''
      <html><body>
        <div id="i3"><a href="https://e-hentai.org/s/abcdef12/12345-3">next</a></div>
      </body></html>
      ''';
      expect(GalleryImageParser.parseNextPageToken(html), 'abcdef12');
    });

    test('parseApiImageUrl extracts URL from JSON', () {
      const json = '{"i":"https:\\/\\/example.com\\/image.jpg","s":"key"}';
      expect(GalleryImageParser.parseApiImageUrl(json),
          'https://example.com/image.jpg');
    });

    test('parse extracts image from page HTML', () {
      const html = '''
      <html><body>
        <div id="i2"><div>:: 1200 x 1800 :: 500.2 KB</div></div>
        <div id="i3"><a href="https://e-hentai.org/s/next123/12345-4">
          <img id="img" src="https://example.com/full_image.jpg" />
        </a></div>
      </body></html>
      ''';
      final image = GalleryImageParser.parse(html, 2);
      expect(image.index, 2);
      expect(image.imageUrl, 'https://example.com/full_image.jpg');
      expect(image.width, 1200);
      expect(image.height, 1800);
    });
  });
}
