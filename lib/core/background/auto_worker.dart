import 'dart:developer';
import 'package:workmanager/workmanager.dart';
import 'package:drift/drift.dart';
import '../cache/isar_service.dart';
import '../database/local_database.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      log("Background Worker started: $task");
      await IsarService.init();
      final db = LocalDatabase();
      final barangs = await db.select(db.barang).get();
      for (final b in barangs) {
        final logs = await (db.select(db.kartuStok)
          ..where((k) => k.barangId.equals(b.id))
          ..where((k) => k.tipe.equals('KELUAR'))
        ).get();
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final filteredLogs = logs.where((k) => k.tanggal.isAfter(thirtyDaysAgo)).toList();
        final totalKeluar = filteredLogs.fold<int>(0, (sum, item) => sum + item.qty.abs());
        final tor = b.stok == 0 ? 0.0 : totalKeluar / b.stok;
        await IsarService.syncFromDrift(barangId: b.id, nama: b.nama, sku: b.sku??'', stok: b.stok, safetyStock: b.safetyStock, hpp: b.hppAverage, tor: tor.toDouble());
        final logsHpp = await (db.select(db.kartuStok)..where((k) => k.barangId.equals(b.id))..where((k) => k.tipe.equals('MASUK'))).get();
        if (logsHpp.isNotEmpty) {
          log('CCTV HPP ${b.nama}: Rp ${logsHpp.last.hargaBeliSaatItu} | Stok ${b.stok}');
        }
      }
      final jualHariIni = await db.customSelect('SELECT SUM(laba) as total FROM penjualan WHERE tanggal >=?', variables: [Variable.withDateTime(DateTime.now().subtract(const Duration(days:1)))],).getSingle();
      log('CCTV LABA 24J: Rp ${jualHariIni.data['total']??0}');
      return Future.value(true);
    } catch (e, st) {
      log("Error Worker: $e", error: e, stackTrace: st);
      return Future.value(false);
    }
  });
}

class AutoWorker {
  static Future<void> init() async {
    try {
      Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask('sony-jaya-auto-control-task', 'sony-jaya-auto-control', frequency: const Duration(hours: 6), constraints: Constraints(networkType: NetworkType.notRequired, requiresCharging: false, requiresDeviceIdle: false));
    } catch (e) {
      log("Failed init: $e");
    }
  }
}