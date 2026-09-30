import '../database/local_database.dart';

class SafetyStockService {
  // Rumus toko perkakas: Safety = (Rata jual harian x Lead Time 3 hari) + 20%
  static Future<int> hitungBaru(LocalDatabase db, int barangId) async {
    final result = await db.customSelect(
      'SELECT SUM(ABS(qty)) as total FROM kartu_stok WHERE barang_id =? AND tipe = "KELUAR" AND tanggal > datetime("now", "-30 days")',
      variables: [Variable.withInt(barangId)]
    ).getSingle();

    final total30hari = result.data['total'] as int??? 0;
    if (total30hari == 0) return 5; // default barang baru

    final avgHarian = total30hari / 30;
    final safety = (avgHarian * 3 * 1.2).ceil(); // lead time 3 hari + buffer 20%
    return safety < 2? 2 : safety;
  }
}