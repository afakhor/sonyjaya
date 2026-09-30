import 'package:workmanager/workmanager.dart';
import '../cache/isar_service.dart';
import '../database/local_database.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await IsarService.init();
    final db = LocalDatabase();
    // Tiap jam 7 pagi cek barang yang perlu reorder
    final barangs = await db.select(db.barang).get();
    for (final b in barangs) {
      if (b.stok <= b.safetyStock) {
        // Nanti kirim notif lokal
        print('REORDER: ${b.nama} stok ${b.stok} <= ${b.safetyStock}');
      }
    }
    return Future.value(true);
  });
}

void initAutoWorker() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask('reorder-check', 'reorder-check', frequency: const Duration(hours: 6));
}