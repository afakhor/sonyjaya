import 'package:workmanager/workmanager.dart';
import '../cache/isar_service.dart';
import '../database/local_database.dart';
import '../services/auto_po_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await IsarService.init();
    final db = LocalDatabase();
    
    // 1. Sinkronisasi & Cek Reorder Cache
    final barangs = await db.select(db.barang).get();
    for (final b in barangs) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final logs = await (db.select(db.kartuStok)
        ..where((k) => k.barangId.equals(b.id) & k.tipe.equals('KELUAR') & k.tanggal.isBiggerThanValue(thirtyDaysAgo))
      ).get();
      
      final totalKeluar = logs.fold<int>(0, (sum, item) => sum + item.qty.abs());
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

    // 2. Auto-Draft PO Background check
    final draftPo = await AutoPoService.generateDraftPo(db);
    if (draftPo.isNotEmpty) {
      print('AUTO-PO: Terdeteksi ${draftPo.length} item di bawah safety stock. Draf siap dikirim.');
    }

    return Future.value(true);
  });
}

void initAutoWorker() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask('sony-jaya-auto-control', 'sony-jaya-auto-control', frequency: const Duration(hours: 6));
}
