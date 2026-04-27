import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class CookieManager {
  static final _log = Logger();
  late final PersistCookieJar _cookieJar;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    final cookiePath = '${dir.path}/.cookies/';
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(cookiePath),
    );
    _initialized = true;
    _log.i('CookieManager initialized at $cookiePath');
  }

  PersistCookieJar get cookieJar {
    assert(_initialized, 'CookieManager not initialized. Call init() first.');
    return _cookieJar;
  }

  Future<void> saveLoginCookies({
    required String memberId,
    required String passHash,
    String? igneous,
  }) async {
    final ehUri = Uri.parse(AppConstants.ehBaseUrl);
    final exUri = Uri.parse(AppConstants.exBaseUrl);

    // Create separate cookie lists per domain to avoid mutation issues
    // (saveFromResponse may modify cookie.domain in place)
    List<Cookie> makeCookies(String domain) {
      final list = [
        Cookie(AppConstants.cookieIpbMemberId, memberId)
          ..domain = domain
          ..path = '/',
        Cookie(AppConstants.cookieIpbPassHash, passHash)
          ..domain = domain
          ..path = '/',
      ];
      if (igneous != null && igneous.isNotEmpty) {
        list.add(Cookie(AppConstants.cookieIgneous, igneous)
          ..domain = domain
          ..path = '/');
      }
      return list;
    }

    await _cookieJar.saveFromResponse(ehUri, makeCookies('.e-hentai.org'));
    await _cookieJar.saveFromResponse(exUri, makeCookies('.exhentai.org'));
    _log.i('Login cookies saved for both domains');
  }

  Future<bool> hasLoginCookies() async {
    final ehUri = Uri.parse(AppConstants.ehBaseUrl);
    final cookies = await _cookieJar.loadForRequest(ehUri);
    return cookies.any((c) => c.name == AppConstants.cookieIpbMemberId);
  }

  Future<String?> getMemberId() async {
    final ehUri = Uri.parse(AppConstants.ehBaseUrl);
    final cookies = await _cookieJar.loadForRequest(ehUri);
    try {
      return cookies
          .firstWhere((c) => c.name == AppConstants.cookieIpbMemberId)
          .value;
    } catch (_) {
      return null;
    }
  }

  /// Ensure ExHentai has the same login cookies as E-Hentai.
  /// Call when switching to ExHentai mode to fix missing/stale cookies.
  Future<void> syncCookiesToExHentai() async {
    final ehUri = Uri.parse(AppConstants.ehBaseUrl);
    final exUri = Uri.parse(AppConstants.exBaseUrl);
    final ehCookies = await _cookieJar.loadForRequest(ehUri);

    String? memberId;
    String? passHash;
    String? igneous;
    for (final c in ehCookies) {
      if (c.name == AppConstants.cookieIpbMemberId) memberId = c.value;
      if (c.name == AppConstants.cookieIpbPassHash) passHash = c.value;
      if (c.name == AppConstants.cookieIgneous) igneous = c.value;
    }

    if (memberId == null || passHash == null) return;

    final exCookies = [
      Cookie(AppConstants.cookieIpbMemberId, memberId)
        ..domain = '.exhentai.org'
        ..path = '/',
      Cookie(AppConstants.cookieIpbPassHash, passHash)
        ..domain = '.exhentai.org'
        ..path = '/',
    ];
    if (igneous != null && igneous.isNotEmpty) {
      exCookies.add(Cookie(AppConstants.cookieIgneous, igneous)
        ..domain = '.exhentai.org'
        ..path = '/');
    }

    await _cookieJar.saveFromResponse(exUri, exCookies);
    _log.i('Synced login cookies to ExHentai domain');
  }

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
    _log.i('All cookies cleared');
  }
}
