import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/fast_stock_cache.dart';

class IsarService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open(
        [FastStockCacheSchema],
        directory: dir.path,
        name: 'sony_jaya_cache',
      );
    } else {
      isar = Isar.getInstance('sony_jaya_cache') ?? await Isar.open(
        [FastStockCacheSchema],
        directory: dir.path,
        name: 'sony_jaya_cache',
      );
    }
  }

  static Future<void> syncFromDrift({
    required int barangId,
    required String nama,
    required String sku,
    required int stok,
    required int safetyStock,
    required double hpp,
    required double tor,
  }) async {
    final cache = FastStockCache()
      ..barangId = barangId
      ..nama = nama
      ..sku = sku
      ..stok = stok
      ..safetyStock = safetyStock
      ..hppAverage = hpp
      ..tor = tor
      ..isFastMoving = tor > 2.5
      ..perluReorder = stok <= safetyStock
      ..lastUpdated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.fastStockCaches.putByBarangId(cache);
    });
  }

  static Stream<List<FastStockCache>> watchFastMoving() {
    return isar.fastStockCaches.filter().isFastMovingEqualTo(true).watch(fireImmediately: true);
  }

  static Stream<List<FastStockCache>> watchPerluReorder() {
    return isar.fastStockCaches.filter().perluReorderEqualTo(true).watch(fireImmediately: true);
  }
}
