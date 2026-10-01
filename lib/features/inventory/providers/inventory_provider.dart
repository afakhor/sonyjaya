import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/local_database.dart';
import '../../core/cache/isar_service.dart';

part 'inventory_provider.g.dart';

@riverpod
LocalDatabase localDb(LocalDbRef ref) => LocalDatabase();

@riverpod
class Inventory extends _$Inventory {
  @override
  Stream<List<BarangData>> build() {
    final db = ref.watch(localDbProvider);
    return db.barangDao.watchAllBarang();
  }

  Future<void> beli({required int barangId, required int qty, required double harga}) async {
    final db = ref.read(localDbProvider);
    await db.transaksiDao.prosesPembelian(barangId: barangId, qtyPcs: qty, hargaBeli: harga);
    await _refreshCache(barangId);
  }

  Future<void> jual({required int barangId, required int qty, required double hargaJual}) async {
    final db = ref.read(localDbProvider);
    await db.transaksiDao.prosesPenjualan(barangId: barangId, qtyPcs: qty, hargaJual: hargaJual);
    await _refreshCache(barangId);
  }

  Future<void> _refreshCache(int barangId) async {
    final db = ref.read(localDbProvider);
    final barang = await (db.select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();

    // Hitung TOR simpel: total keluar 30 hari / stok rata-rata
    final keluar30hari = await db.customSelect(
      'SELECT SUM(ABS(qty)) as total FROM kartu_stok WHERE barang_id = ? AND tipe = "KELUAR" AND tanggal > datetime("now", "-30 days")',
      variables: [Variable.withInt(barangId)]
    ).getSingle();
    
    // Perbaikan casting agar aman dari null dan tipe data num
    final rawTotal = keluar30hari.data['total'];
    final totalKeluar = rawTotal != null ? (rawTotal as num).toInt() : 0;
    final tor = barang.stok == 0 ? 0.0 : totalKeluar / barang.stok;

    await IsarService.syncFromDrift(
      barangId: barang.id, 
      nama: barang.nama, 
      sku: barang.sku,
      stok: barang.stok, 
      safetyStock: barang.safetyStock,
      hpp: barang.hppAverage, 
      tor: tor.toDouble()
    );
  }
}
