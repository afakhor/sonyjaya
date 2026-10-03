import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/local_database.dart';
import '../../../core/cache/isar_service.dart';

final localDbProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final inventoryStreamProvider = StreamProvider.autoDispose<List<BarangData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.barangDao.watchAllBarang();
});

final inventoryControllerProvider = Provider<InventoryController>((ref) => InventoryController(ref));

class InventoryController {
  final Ref _ref;
  InventoryController(this._ref);

  Future<void> beli({
    required int barangId,
    required int qty,
    required double harga,
    bool isSatuanBesar = false,
    String? supplier,
    DateTime? tanggal, // FIX TANGGAL
    String? nota,
  }) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesPembelian(
      barangId: barangId,
      qtyInput: qty,
      hargaBeliPerSatuanInput: harga,
      isSatuanBesar: isSatuanBesar,
      supplier: supplier,
      tanggal: tanggal,
      refId: nota,
    );
    await refreshCache(barangId);
  }

  Future<void> jual({required int barangId, required int qty, required double hargaJual, bool isSatuanBesar = false, String tipe = 'eceran'}) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesPenjualan(barangId: barangId, qtyInput: qty, hargaJualPerSatuanInput: hargaJual, isSatuanBesar: isSatuanBesar, tipe: tipe);
    await refreshCache(barangId);
  }

  Future<void> opname({required int barangId, required int stokFisik, String? keterangan}) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesStockOpname(barangId: barangId, stokFisik: stokFisik, keterangan: keterangan);
    await refreshCache(barangId);
  }

  Future<void> refreshCache(int barangId) async {
    final db = _ref.read(localDbProvider);
    final barang = await (db.select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final keluar30hari = await db.customSelect(
      'SELECT SUM(ABS(qty)) as total FROM kartu_stok WHERE barang_id = ? AND tipe = "KELUAR" AND tanggal > ?',
      variables: [Variable.withInt(barangId), Variable.withDateTime(thirtyDaysAgo)],
    ).getSingle();
    final rawTotal = keluar30hari.data['total'];
    final totalKeluar = rawTotal != null ? (rawTotal as num).toInt() : 0;
    final tor = barang.stok == 0 ? 0.0 : totalKeluar / barang.stok;
    await IsarService.syncFromDrift(barangId: barang.id, nama: barang.nama, sku: barang.sku ?? '', stok: barang.stok, safetyStock: barang.safetyStock, hpp: barang.hppAverage, tor: tor.toDouble());
  }

  Future<void> refreshCacheAfterCheckout(int barangId) async => refreshCache(barangId);
}