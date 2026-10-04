import 'dart:developer';
import 'package:workmanager/workmanager.dart';
import 'package:drift/drift.dart';
import '../cache/isar_service.dart';
import '../cache/models/fast_stock_cache.dart';
import '../database/local_database.dart';


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      log("🤖 ROBOTIC BRAIN START: $task");
      await IsarService.init();
      final db = LocalDatabase();
      final barangs = await db.select(db.barang).get();
      final List<FastStockCache> bulk = [];
      for (final b in barangs) {
        final logsKeluar = await (db.select(db.kartuStok)..where((k)=>k.barangId.equals(b.id))..where((k)=>k.tipe.equals('KELUAR'))).get();
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days:30));
        final filtered = logsKeluar.where((k)=>k.tanggal.isAfter(thirtyDaysAgo)).toList();
        final totalKeluar = filtered.fold<int>(0, (sum,item)=>sum+item.qty.abs());
        final tor = b.stok==0?0.0:totalKeluar / b.stok;
        final dynamicSafety = tor>2.5? (b.safetyStock*1.5).toInt() : b.safetyStock;
        if(dynamicSafety!=b.safetyStock){ await db.barangDao.updateSafetyStock(b.id, dynamicSafety); }
        bulk.add(FastStockCache()..barangId=b.id..nama=b.nama..sku=b.sku??''..stok=b.stok..safetyStock=dynamicSafety..hppAverage=b.hppAverage..tor=tor..isFastMoving=tor>2.5..perluReorder=b.stok<=dynamicSafety..lastUpdated=DateTime.now());
      }
      await IsarService.bulkSync(bulk);
      final jual = await db.customSelect('SELECT SUM(laba) as total FROM penjualan WHERE tanggal >=?', variables: [Variable.withDateTime(DateTime.now().subtract(const Duration(days:1)))],).getSingle();
      log('💰 LABA 24J: Rp ${jual.data['total']??0} | FAST ${bulk.where((e)=>e.isFastMoving).length} | REORDER ${bulk.where((e)=>e.perluReorder).length}');
      return Future.value(true);
    } catch(e,st){ log("❌ Error Worker: $e", error:e, stackTrace:st); return Future.value(false); }
  });
}
class AutoWorker {
  static Future<void> init() async {
    try {
      Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask('sony-jaya-auto-control-task', 'sony-jaya-auto-control', frequency: const Duration(hours:6), constraints: Constraints(networkType: NetworkType.notRequired, requiresCharging: false, requiresDeviceIdle: false), existingWorkPolicy: ExistingWorkPolicy.replace);
    } catch(e){ log("Failed init: $e"); }
  }
}
