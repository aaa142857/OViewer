import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/parser/gallery_list_parser.dart';
import '../core/storage/database.dart';
import '../models/gallery_preview.dart';

class FavoritesRepository {
  final DioClient _dio;
  final AppDatabase _db;

  FavoritesRepository(this._dio, this._db);

  // --- Cloud Favorites (requires login) ---

  /// Fetch cloud favorites
  Future<FavoritesResult> fetchCloudFavorites({
    int page = 0,
    int cat = -1,
  }) async {
    final url = ApiEndpoints.favorites(page: page, cat: cat);
    final html = await _dio.get(url);
    final galleries = GalleryListParser.parse(html);
    final pageCount = GalleryListParser.parsePageCount(html);
    return FavoritesResult(galleries: galleries, totalPages: pageCount);
  }

  /// Add to cloud favorites (auto-caches locally)
  Future<void> addCloudFavorite(int gid, String token, {int slot = 0, GalleryPreview? preview}) async {
    // Write local cache first so other screens see the update immediately
    if (preview != null) {
      await _db.addLocalFavorite(LocalFavoritesCompanion(
        gid: Value(preview.gid),
        token: Value(preview.token),
        title: Value(preview.title),
        thumbUrl: Value(preview.thumbUrl),
        category: Value(preview.category),
        rating: Value(preview.rating),
        fileCount: Value(preview.fileCount),
        slot: Value(slot),
        addedAt: Value(DateTime.now()),
      ));
    }
    try {
      final url = ApiEndpoints.addFavorite(gid, token);
      await _dio.post(url, data: FormData.fromMap({
        'favcat': slot.toString(),
        'favnote': '',
        'apply': 'Add to Favorites',
        'update': '1',
      }));
    } catch (_) {
      // Revert local cache on API failure
      await _db.removeLocalFavorite(gid);
      rethrow;
    }
  }

  /// Remove cloud favorite (auto-removes local cache)
  Future<void> removeCloudFavorite(int gid, String token) async {
    // Save existing entry for rollback, then remove immediately
    final existing = await _db.getLocalFavorite(gid);
    await _db.removeLocalFavorite(gid);
    try {
      final url = ApiEndpoints.addFavorite(gid, token);
      await _dio.post(url, data: FormData.fromMap({
        'favcat': 'favdel',
        'apply': 'Apply Changes',
        'update': '1',
      }));
    } catch (_) {
      // Revert local cache on API failure
      if (existing != null) {
        await _db.addLocalFavorite(LocalFavoritesCompanion(
          gid: Value(existing.gid),
          token: Value(existing.token),
          title: Value(existing.title),
          thumbUrl: Value(existing.thumbUrl),
          category: Value(existing.category),
          rating: Value(existing.rating),
          fileCount: Value(existing.fileCount),
          slot: Value(existing.slot),
          addedAt: Value(existing.addedAt),
        ));
      }
      rethrow;
    }
  }

  // --- Local cache (used by _markFavorites) ---

  Future<Set<int>> getLocalFavoriteGids() =>
      _db.getLocalFavoriteGids();

  /// Rebuild local cache from cloud results
  Future<void> rebuildCache(List<GalleryPreview> galleries) async {
    // Clear existing cache then insert fresh data
    await _db.clearLocalFavorites();
    for (final g in galleries) {
      await _db.addLocalFavorite(LocalFavoritesCompanion(
        gid: Value(g.gid),
        token: Value(g.token),
        title: Value(g.title),
        thumbUrl: Value(g.thumbUrl),
        category: Value(g.category),
        rating: Value(g.rating),
        fileCount: Value(g.fileCount),
        slot: const Value(0),
        addedAt: Value(DateTime.now()),
      ));
    }
  }
}

class FavoritesResult {
  final List<GalleryPreview> galleries;
  final int totalPages;

  const FavoritesResult({required this.galleries, required this.totalPages});
}
