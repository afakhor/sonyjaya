import 'dart:developer';
import 'package:workmanager/workmanager.dart';
import '../cache/isar_service.dart';
import '../database/local_database.dart';
// Sesuaikan path jika auto_po_service langsung di dalam folder po/ atau services/
import '../../features/po/auto_po_service.dart'; 

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      log("Background Worker started execution: $task");

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

        await IsarService.syncFromDrift(
          barangId: b.id,
          nama: b.nama,
          sku: b.sku ?? '',
          stok: b.stok,
          safetyStock: b.safetyStock,
          hpp: b.hppAverage,
          tor: tor.toDouble(),
        );
      }

      final draftPo = await AutoPoService.generateDraftPo(db);
      if (draftPo.isNotEmpty) {
        log('AUTO-PO BACKGROUND: Terdeteksi ${draftPo.length} item di bawah safety stock.');
      }

      return Future.value(true);
    } catch (e, stackTrace) {
      log("Error in Background Worker: $e", error: e, stackTrace: stackTrace);
      return Future.value(false);
    }
  });
}

class AutoWorker {
  static Future<void> init() async {
    try {
      Workmanager().initialize(
        callbackDispatcher, 
        isInDebugMode: false,
      );

      await Workmanager().registerPeriodicTask(
        'sony-jaya-auto-control-task', 
        'sony-jaya-auto-control', 
        frequency: const Duration(hours: 6),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresCharging: false,
          requiresDeviceIdle: false,
        ),
      );

      log("AutoWorker background initialized successfully.");
    } catch (e) {
      log("Failed to initialize Workmanager: $e");
    }
  }
}
