import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

/// Custom [CacheManager] that injects cookies from the [PersistCookieJar]
/// into every image request. This is required for ExHentai, which returns
/// 403 / a blank sad-panda page when cookies are missing.
class EhImageCacheManager extends CacheManager {
  static const _key = 'ehImageCache';
  static EhImageCacheManager? _instance;

  static EhImageCacheManager get instance {
    assert(_instance != null,
        'EhImageCacheManager not initialised. Call init() first.');
    return _instance!;
  }

  /// Call once during app startup, after [CookieManager.init].
  static void init(PersistCookieJar cookieJar) {
    _instance = EhImageCacheManager._(cookieJar);
  }

  EhImageCacheManager._(PersistCookieJar cookieJar)
      : super(Config(
          _key,
          fileService: _CookieHttpFileService(cookieJar),
        ));
}

class _CookieHttpFileService extends HttpFileService {
  final PersistCookieJar _cookieJar;

  _CookieHttpFileService(this._cookieJar);

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    final cookies = await _cookieJar.loadForRequest(uri);
    final cookieHeader =
        cookies.map((c) => '${c.name}=${c.value}').join('; ');

    final merged = Map<String, String>.from(headers ?? {});
    if (cookieHeader.isNotEmpty) {
      merged['Cookie'] = cookieHeader;
    }
    // Match the User-Agent used by DioClient so servers see consistent requests.
    merged['User-Agent'] =
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
        'Mobile/15E148 Safari/604.1';

    return super.get(url, headers: merged);
  }
}
