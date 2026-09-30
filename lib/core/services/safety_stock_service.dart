import '../database/local_database.dart';

class SafetyStockService {
  // Rumus toko perkakas: Safety = (Rata jual harian x Lead Time 3 hari) + 20%
  static Future<int> hitungBaru(LocalDatabase db, int barangId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final logs = await (db.select(db.kartuStok)
          ..where((k) => k.barangId.equals(barangId))
          ..where((k) => k.tipe.equals('KELUAR'))
          ..where((k) => k.tanggal.isBiggerThanValue(thirtyDaysAgo)))
        .get();

    final total30hari = logs.fold<int>(0, (p, e) => p + e.qty.abs());
    if (total30hari == 0) return 5;

    final avgHarian = total30hari / 30;
    final safety = (avgHarian * 3 * 1.2).ceil();
    return safety < 2 ? 2 : safety;
  }
}