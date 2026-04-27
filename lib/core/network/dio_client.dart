import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import 'cookie_manager.dart' as app;
import 'api_exception.dart';

class DioClient {
  static final _log = Logger();
  late final Dio _dio;
  final app.CookieManager _cookieManager;

  DioClient(this._cookieManager) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
                'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
                'Mobile/15E148 Safari/604.1',
      },
      responseType: ResponseType.plain,
    ));

    // Cookie interceptor
    _dio.interceptors.add(
      CookieManager(_cookieManager.cookieJar),
    );

    // Logging interceptor (debug only)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _log.d('REQUEST: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _log.d('RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        _log.e('ERROR: ${error.message} ${error.requestOptions.uri}');
        handler.next(error);
      },
    ));
  }

  Future<String> get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParams,
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Set HTTP/SOCKS5 proxy for all requests.
  /// Format: "http://host:port" or "socks5://host:port"
  void setProxy(String? proxyUrl) {
    if (proxyUrl == null || proxyUrl.isEmpty) {
      // Remove proxy - use default adapter
      _dio.httpClientAdapter = IOHttpClientAdapter();
      _log.i('Proxy cleared');
      return;
    }

    String proxyAddress;
    if (proxyUrl.startsWith('socks5://')) {
      // For SOCKS5: PROXY host:port
      proxyAddress = 'PROXY ${proxyUrl.replaceFirst('socks5://', '')}';
    } else if (proxyUrl.startsWith('http://') ||
        proxyUrl.startsWith('https://')) {
      proxyAddress =
          'PROXY ${proxyUrl.replaceFirst(RegExp(r'https?://'), '')}';
    } else {
      proxyAddress = 'PROXY $proxyUrl';
    }

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) => proxyAddress;
        // Allow self-signed certs for proxy
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
    _log.i('Proxy set to: $proxyAddress');
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode == 401 || statusCode == 403) {
          return ApiException.unauthorized();
        }
        if (statusCode == 509) {
          return ApiException.banned();
        }
        return ApiException.server(statusCode);
      case DioExceptionType.connectionError:
        return ApiException.network();
      default:
        return ApiException(
          message: error.message ?? 'Unknown network error',
          originalError: error,
        );
    }
  }
}
