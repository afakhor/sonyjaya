import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/local_database.dart';
import '../../../core/cache/isar_service.dart';

// 1. Provider Singleton Database Utama dengan Manajemen Disposal
final localDbProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// 2. Stream Provider untuk Sinkronisasi Real-time UI Inventory
final inventoryStreamProvider = StreamProvider.autoDispose<List<BarangData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.barangDao.watchAllBarang();
});

// 3. Controller Provider untuk Eksekusi Logika Bisnis Inventory
final inventoryControllerProvider = Provider<InventoryController>((ref) {
  return InventoryController(ref);
});

class InventoryController {
  final Ref _ref;
  InventoryController(this._ref);

  /// Aksi Pembelian Stok (Restok Barang / Masuk)
  Future<void> beli({
    required int barangId,
    required int qty,
    required double harga,
    bool isSatuanBesar = false,
    String? supplier,
  }) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesPembelian(
      barangId: barangId,
      qtyInput: qty,
      hargaBeliPerSatuanInput: harga,
      isSatuanBesar: isSatuanBesar,
      supplier: supplier,
    );
    await refreshCache(barangId);
  }

  /// Aksi Penjualan Stok (Eceran / Grosir / Kasir)
  Future<void> jual({
    required int barangId,
    required int qty,
    required double hargaJual,
    bool isSatuanBesar = false,
    String tipe = 'eceran',
  }) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesPenjualan(
      barangId: barangId,
      qtyInput: qty,
      hargaJualPerSatuanInput: hargaJual,
      isSatuanBesar: isSatuanBesar,
      tipe: tipe,
    );
    await refreshCache(barangId);
  }

  /// Aksi Stock Opname (Koreksi Fisik Gudang)
  Future<void> opname({
    required int barangId,
    required int stokFisik,
    String? keterangan,
  }) async {
    final db = _ref.read(localDbProvider);
    await db.transaksiDao.prosesStockOpname(
      barangId: barangId,
      stokFisik: stokFisik,
      keterangan: keterangan,
    );
    await refreshCache(barangId);
  }

  /// Hitung Ulang TOR (Turnover Ratio) & Sinkronisasi Cache Isar Fast-Read
  Future<void> refreshCache(int barangId) async {
    final db = _ref.read(localDbProvider);
    final barang = await (db.select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();

    // Hitung titik potong 30 hari lalu secara presisi dari Dart
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final keluar30hari = await db.customSelect(
      'SELECT SUM(ABS(qty)) as total FROM kartu_stok WHERE barang_id = ? AND tipe = "KELUAR" AND tanggal > ?',
      variables: [
        Variable.withInt(barangId),
        Variable.withDateTime(thirtyDaysAgo),
      ],
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

  /// Alias pemanggilan pasca-checkout (kompatibilitas dengan KasirNotifier)
  Future<void> refreshCacheAfterCheckout(int barangId) async {
    await refreshCache(barangId);
  }
}
