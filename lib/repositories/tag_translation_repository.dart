import 'dart:convert';
import 'package:logger/logger.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/storage/local_storage.dart';

class TagTranslationRepository {
  static final _log = Logger();
  final DioClient _dio;
  final LocalStorage _storage;

  /// namespace -> { tagKey -> translatedName }
  Map<String, Map<String, String>> _translations = {};
  bool _loaded = false;

  TagTranslationRepository(this._dio, this._storage);

  bool get isLoaded => _loaded;

  /// Load translations: try local cache first, then fetch remote.
  Future<void> loadTranslations() async {
    // Try loading from local cache
    final cached = _storage.prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        _parseJsonData(cached);
        _loaded = true;
        _log.i('Tag translations loaded from cache '
            '(${_translations.length} namespaces)');
        // Refresh in background
        _fetchAndCache();
        return;
      } catch (_) {
        // Cache corrupted, fetch fresh
      }
    }

    await _fetchAndCache();
  }

  Future<void> _fetchAndCache() async {
    try {
      final jsonStr = await _dio.get(ApiEndpoints.ehTagTranslationUrl);
      _parseJsonData(jsonStr);
      _loaded = true;
      // Cache locally
      await _storage.prefs.setString(_cacheKey, jsonStr);
      _log.i('Tag translations fetched and cached '
          '(${_translations.length} namespaces)');
    } catch (e) {
      _log.w('Failed to fetch tag translations: $e');
    }
  }

  void _parseJsonData(String jsonStr) {
    final data = json.decode(jsonStr);
    final result = <String, Map<String, String>>{};

    // EhTagTranslation db.text.json format:
    // { "data": [ { "namespace": "...", "data": { "tagKey": { "name": "..." } } } ] }
    if (data is Map && data.containsKey('data')) {
      final dataList = data['data'] as List;
      for (final nsEntry in dataList) {
        final namespace = nsEntry['namespace'] as String? ?? '';
        final tags = nsEntry['data'] as Map<String, dynamic>? ?? {};
        final nsMap = <String, String>{};
        for (final entry in tags.entries) {
          final tagData = entry.value;
          if (tagData is Map && tagData.containsKey('name')) {
            nsMap[entry.key] = tagData['name'] as String;
          }
        }
        if (nsMap.isNotEmpty) {
          result[namespace] = nsMap;
        }
      }
    }

    _translations = result;
  }

  /// Get translation for a specific tag.
  String? getTranslation(String namespace, String key) {
    return _translations[namespace]?[key];
  }

  /// Get all translations for a namespace.
  Map<String, String>? getNamespaceTranslations(String namespace) {
    return _translations[namespace];
  }

  /// Search tags by translated name (for autocomplete).
  List<TagSearchResult> searchByTranslation(String query, {int limit = 20}) {
    if (!_loaded || query.isEmpty) return [];
    final results = <TagSearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final nsEntry in _translations.entries) {
      for (final tagEntry in nsEntry.value.entries) {
        if (tagEntry.value.toLowerCase().contains(lowerQuery) ||
            tagEntry.key.toLowerCase().contains(lowerQuery)) {
          results.add(TagSearchResult(
            namespace: nsEntry.key,
            key: tagEntry.key,
            translation: tagEntry.value,
          ));
          if (results.length >= limit) return results;
        }
      }
    }
    return results;
  }

  static const _cacheKey = 'eh_tag_translations_cache';
}

class TagSearchResult {
  final String namespace;
  final String key;
  final String translation;

  const TagSearchResult({
    required this.namespace,
    required this.key,
    required this.translation,
  });

  String get fullTag => '$namespace:$key';
}
