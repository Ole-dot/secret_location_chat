import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';

/// Persistent on-disk cache for [flutter_map] tiles.
class MapTileCache {
  static CacheStore? _store;

  static CacheStore? get store => _store;

  static Future<void> initialize() async {
    if (_store != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _store = HiveCacheStore(
      dir.path,
      hiveBoxName: 'slc_map_tiles',
    );
  }
}
