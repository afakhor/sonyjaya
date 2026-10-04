import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/fast_stock_cache.dart';
class IsarService {
  static late Isar isar;
  static bool _isReady = false;
  static bool get isReady => _isReady;
  static Future<void> init() async {
    if(_isReady && Isar.instanceNames.isNotEmpty) return;
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) { isar = await Isar.open([FastStockCacheSchema], directory: dir.path, name: 'sony_jaya_cache'); } else { isar = Isar.getInstance('sony_jaya_cache') ?? await Isar.open([FastStockCacheSchema], directory: dir.path, name: 'sony_jaya_cache'); }
    _isReady = true;
  }
  static Future<void> syncFromDrift({required int barangId, required String nama, required String sku, required int stok, required int safetyStock, required double hpp, required double tor}) async {
    if(!_isReady) await init();
    final cache = FastStockCache()..barangId = barangId..nama = nama..sku = sku..stok = stok..safetyStock = safetyStock..hppAverage = hpp..tor = tor..isFastMoving = tor > 2.5..perluReorder = stok <= safetyStock..lastUpdated = DateTime.now();
    await isar.writeTxn(() async { final ex = await isar.fastStockCaches.filter().barangIdEqualTo(barangId).findFirst(); if(ex!=null) cache.id = ex.id; await isar.fastStockCaches.put(cache); });
  }
  static Future<void> bulkSync(List<FastStockCache> list) async { if(!_isReady) await init(); await isar.writeTxn(() async => await isar.fastStockCaches.putAll(list)); }
  static Stream<List<FastStockCache>> watchFastMoving() { if(!_isReady) return Stream.value([]); return isar.fastStockCaches.filter().isFastMovingEqualTo(true).sortByTorDesc().watch(fireImmediately: true); }
  static Stream<List<FastStockCache>> watchPerluReorder() { if(!_isReady) return Stream.value([]); return isar.fastStockCaches.filter().perluReorderEqualTo(true).sortByStok().watch(fireImmediately: true); }
  static Future<List<FastStockCache>> getAllCache() async { if(!_isReady) await init(); return isar.fastStockCaches.where().findAll(); }
}
