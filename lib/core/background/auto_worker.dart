import 'dart:developer';
import 'package:workmanager/workmanager.dart';
import '../cache/isar_service.dart';
import '../database/local_database.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      log("Background Worker started execution: $task");

      // 1. Inisialisasi Isar Cache di background isolate
      await IsarService.init();

      // 2. Inisialisasi Drift Local Database
      final db = LocalDatabase();

      // 3. Ambil seluruh data barang untuk dianalisis stok & TOR (Turnover Ratio)
      final barangs = await db.select(db.barang).get();

      for (final b in barangs) {
        // Ambil log transaksi keluar untuk barang ini dari Drift
        final logs = await (db.select(db.kartuStok)
          ..where((k) => k.barangId.equals(b.id))
          ..where((k) => k.tipe.equals('KELUAR'))
        ).get();

        // Filter tanggal 30 hari terakhir di sisi Dart
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final filteredLogs = logs.where((k) => k.tanggal.isAfter(thirtyDaysAgo)).toList();

        final totalKeluar = filteredLogs.fold<int>(0, (sum, item) => sum + item.qty.abs());
        final tor = b.stok == 0 ? 0.0 : totalKeluar / b.stok;

        // Sinkronisasi data ke Isar Fast Cache
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

      // 4. Deteksi otomatis barang yang di bawah safety stock untuk keperluan stok kritis
      final lowStockItems = barangs.where((b) => b.stok <= b.safetyStock).toList();
      if (lowStockItems.isNotEmpty) {
        log('AUTO-WORKER BACKGROUND: Terdeteksi ${lowStockItems.length} item di bawah safety stock.');
        // Anda bisa menambahkan logika penyimpanan draft PO otomatis langsung ke database Drift di sini jika diperlukan.
      }

      log("Background Worker successfully finished task.");
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

      // Daftarkan tugas periodik setiap 6 jam sekali
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

      log("AutoWorker background initialized and registered successfully.");
    } catch (e) {
      log("Failed to initialize Workmanager: $e");
    }
  }
}
