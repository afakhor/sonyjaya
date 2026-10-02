import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../../core/cache/isar_service.dart';

final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

final inventoryStreamProvider = StreamProvider.autoDispose<List<BarangData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.barangDao.watchAllBarang();
});

final inventoryControllerProvider = Provider<InventoryController>((ref) {
  return InventoryController(ref);
});

class InventoryController {
  final Ref _ref;
  InventoryController(this._ref);

  Future<void> beli({required int barangId, required int qty, required double harga}) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesPembelian(
      barangId: barangId,
      qtyInput: qty,
      hargaBeliPerSatuanInput: harga,
    );
    await _refreshCache(barangId);
  }

  Future<void> jual({required int barangId, required int qty, required double hargaJual}) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesPenjualan(
      barangId: barangId,
      qtyInput: qty,
      hargaJualPerSatuanInput: hargaJual,
    );
    await _refreshCache(barangId);
  }

  Future<void> _refreshCache(int barangId) async {
    final db = _ref.read(localDbProvider);
    final barang = await (db.select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();

    final keluar30hari = await db.customSelect(
      'SELECT SUM(ABS(qty)) as total FROM kartu_stok WHERE barang_id = ? AND tipe = "KELUAR" AND tanggal > datetime("now", "-30 days")',
      variables: [Variable.withInt(barangId)]
    ).getSingle();

    final rawTotal = keluar30hari.data['total'];
    final totalKeluar = rawTotal != null ? (rawTotal as num).toInt() : 0;
    final tor = barang.stok == 0 ? 0.0 : totalKeluar / barang.stok;

    await IsarService.syncFromDrift(
      barangId: barang.id, 
      nama: barang.nama, 
      sku: barang.sku ?? '',
      stok: barang.stok, 
      safetyStock: barang.safetyStock,
      hpp: barang.hppAverage, 
      tor: tor.toDouble(),
    );
  }
}

extension InventoryExtension on InventoryController {
  Future<void> refreshCacheAfterCheckout(int barangId) async {
    await _refreshCache(barangId);
  }
}
