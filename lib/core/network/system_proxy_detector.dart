import 'dart:io';
import 'package:logger/logger.dart';

/// Detects system proxy / VPN status and local proxy ports.
///
/// Dart VM on Android does NOT route traffic through VpnService,
/// so even with Clash/v2rayNG VPN active, Dio cannot access blocked sites.
/// The workaround: detect VPN → probe local proxy ports → auto-configure Dio.
class SystemProxyDetector {
  static final _log = Logger();

  /// Common local proxy ports used by popular proxy apps.
  static const List<int> _commonPorts = [
    7890, // Clash default
    7891, // Clash SOCKS
    1080, // Shadowsocks / v2rayNG default SOCKS
    1081, // v2rayNG HTTP
    8080, // Generic HTTP proxy
    8118, // Privoxy
    10808, // v2rayNG SOCKS (alternate)
    10809, // v2rayNG HTTP (alternate)
  ];

  /// Detect system proxy from environment variables.
  static String? detectEnvProxy() {
    final envProxy = Platform.environment['http_proxy'] ??
        Platform.environment['HTTP_PROXY'] ??
        Platform.environment['https_proxy'] ??
        Platform.environment['HTTPS_PROXY'];

    if (envProxy != null && envProxy.isNotEmpty) {
      _log.i('System proxy from env: $envProxy');
      return _normalize(envProxy);
    }

    try {
      final testUri = Uri.parse('https://e-hentai.org');
      final proxyStr = HttpClient.findProxyFromEnvironment(testUri);
      if (proxyStr != 'DIRECT' && proxyStr.startsWith('PROXY ')) {
        final hostPort = proxyStr.substring(6).trim();
        if (hostPort.isNotEmpty) {
          final url = 'http://$hostPort';
          _log.i('System proxy from platform: $url');
          return url;
        }
      }
    } catch (e) {
      _log.w('Failed to detect platform proxy: $e');
    }

    return null;
  }

  /// Check if a VPN interface is active.
  static Future<bool> isVpnActive() async {
    try {
      final interfaces = await NetworkInterface.list();
      _log.i('Network interfaces: ${interfaces.map((i) => i.name).toList()}');
      for (final iface in interfaces) {
        final name = iface.name.toLowerCase();
        if (name.startsWith('tun') ||
            name.startsWith('ppp') ||
            name.startsWith('tap') ||
            name.startsWith('utun')) {
          _log.i('VPN interface detected: ${iface.name}');
          return true;
        }
      }
    } catch (e) {
      _log.w('Failed to check VPN status: $e');
    }
    return false;
  }

  /// Probe localhost for an open proxy port.
  /// Returns "http://127.0.0.1:<port>" if found, null otherwise.
  static Future<String?> probeLocalProxy() async {
    _log.i('Probing local proxy ports: $_commonPorts');
    for (final port in _commonPorts) {
      try {
        final socket = await Socket.connect(
          '127.0.0.1',
          port,
          timeout: const Duration(milliseconds: 500),
        );
        socket.destroy();
        final url = 'http://127.0.0.1:$port';
        _log.i('Local proxy port open: $url');
        return url;
      } catch (e) {
        _log.d('Port $port not open: $e');
      }
    }
    _log.d('No local proxy port found');
    return null;
  }

  /// Full auto-detection: env proxy → VPN + local port probe.
  /// Returns the proxy URL to use, or null for direct connection.
  static Future<AutoProxyResult> detect() async {
    // 1. Environment / platform proxy
    final envProxy = detectEnvProxy();
    if (envProxy != null) {
      return AutoProxyResult(proxyUrl: envProxy, vpnActive: false);
    }

    // 2. Check VPN → probe local proxy
    final vpn = await isVpnActive();
    if (vpn) {
      final localProxy = await probeLocalProxy();
      return AutoProxyResult(proxyUrl: localProxy, vpnActive: true);
    }

    return const AutoProxyResult(proxyUrl: null, vpnActive: false);
  }

  static String _normalize(String proxy) {
    final trimmed = proxy.trim();
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('socks5://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }
}

class AutoProxyResult {
  final String? proxyUrl;
  final bool vpnActive;

  const AutoProxyResult({required this.proxyUrl, required this.vpnActive});
}
