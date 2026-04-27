import 'package:flutter_test/flutter_test.dart';
import 'package:oviewer/core/parser/gallery_list_parser.dart';

void main() {
  group('GalleryListParser', () {
    test('parseRating returns correct values for known CSS offsets', () {
      // 5 stars: x=0, y=-1
      expect(GalleryListParser.parseRating('background-position:0px -1px'),
          5.0);
      // 4 stars: x=-16, y=-1
      expect(GalleryListParser.parseRating('background-position:-16px -1px'),
          4.0);
      // 3.5 stars: x=-32, y=-21
      expect(GalleryListParser.parseRating('background-position:-32px -21px'),
          2.5);
      // 0 stars: x=-80, y=-1
      expect(GalleryListParser.parseRating('background-position:-80px -1px'),
          0.0);
      // Empty style
      expect(GalleryListParser.parseRating(''), 0.0);
    });

    test('parsePageCount returns 1 for empty HTML', () {
      expect(GalleryListParser.parsePageCount('<html></html>'), 1);
    });

    test('parse returns empty list for non-gallery HTML', () {
      final result = GalleryListParser.parse('<html><body>No galleries</body></html>');
      expect(result, isEmpty);
    });

    test('parse extracts gallery from link with /g/ pattern', () {
      const html = '''
      <html><body>
        <table class="itg glte"><tbody>
          <tr>
            <td class="gl1e"><div><a href="https://e-hentai.org/g/12345/abcdef1234/">
              <img src="https://thumb.jpg" />
            </a></div></td>
            <td class="gl2e"><div><a href="https://e-hentai.org/g/12345/abcdef1234/">
              <div class="glink">Test Gallery Title</div>
            </a></div></td>
            <td class="gl3e">
              <div class="cn ct2">Manga</div>
              <div>2024-01-15 12:30</div>
              <div class="ir" style="background-position:-16px -1px;opacity:1"></div>
              <div><a href="/uploader/testuser">testuser</a></div>
              <div>25 pages</div>
            </td>
          </tr>
        </tbody></table>
      </body></html>
      ''';

      final result = GalleryListParser.parse(html);
      expect(result.length, 1);
      expect(result[0].gid, 12345);
      expect(result[0].token, 'abcdef1234');
      expect(result[0].title, 'Test Gallery Title');
      expect(result[0].category, 'Manga');
      expect(result[0].rating, 4.0);
      expect(result[0].fileCount, 25);
    });

    test('parse extracts fileCount from td.gl4c div', () {
      const html = '''
      <html><body>
        <table class="itg glte"><tbody>
          <tr>
            <td class="gl1e"><div><a href="https://e-hentai.org/g/99999/aabb112233/">
              <img src="https://thumb.jpg" />
            </a></div></td>
            <td class="gl2e"><div><a href="https://e-hentai.org/g/99999/aabb112233/">
              <div class="glink">Gallery With GL4C</div>
            </a></div></td>
            <td class="gl3e">
              <div class="cn ct2">Doujinshi</div>
              <div>2024-06-01 08:00</div>
              <div class="ir" style="background-position:0px -1px;opacity:1"></div>
              <div><a href="/uploader/someone">someone</a></div>
            </td>
            <td class="gl4c glhide">
              <div><a href="https://e-hentai.org/uploader/someone">someone</a></div>
              <div>42 pages</div>
            </td>
          </tr>
        </tbody></table>
      </body></html>
      ''';

      final result = GalleryListParser.parse(html);
      expect(result.length, 1);
      expect(result[0].fileCount, 42);
    });

    test('extractInt handles comma-separated numbers', () {
      expect(GalleryListParser.extractInt('1,234 pages'), 1234);
      expect(GalleryListParser.extractInt('5 pages'), 5);
      expect(GalleryListParser.extractInt('no number'), 0);
    });

    test('extractPageCount targets number before "page(s)"', () {
      // Normal cases
      expect(GalleryListParser.extractPageCount('25 pages'), 25);
      expect(GalleryListParser.extractPageCount('1,234 pages'), 1234);
      // Singular form
      expect(GalleryListParser.extractPageCount('1 page'), 1);
      // Title with numbers before page count
      expect(GalleryListParser.extractPageCount('Vol.12 Chap.3 45 pages'), 45);
      expect(GalleryListParser.extractPageCount('[2024] Gallery 123 pages'), 123);
      // No match
      expect(GalleryListParser.extractPageCount('no page info'), 0);
    });
  });
}
