import 'package:workmanager/workmanager.dart';
import '../cache/isar_service.dart';
import '../database/local_database.dart';
import '../services/auto_po_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await IsarService.init();
    final db = LocalDatabase();
    
    final barangs = await db.select(db.barang).get();
    for (final b in barangs) {
      // Ambil log transaksi keluar untuk barang ini dari Drift
      final logs = await (db.select(db.kartuStok)
        ..where((k) => k.barangId.equals(b.id))
        ..where((k) => k.tipe.equals('KELUAR'))
      ).get();
      
      // Filter tanggal 30 hari terakhir di sisi Dart (Aman dari perbedaan versi Drift)
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
      print('AUTO-PO: Terdeteksi ${draftPo.length} item di bawah safety stock.');
    }

    return Future.value(true);
  });
}

void initAutoWorker() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask('sony-jaya-auto-control', 'sony-jaya-auto-control', frequency: const Duration(hours: 6));
}
