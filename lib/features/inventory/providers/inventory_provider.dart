import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/local_database.dart';
import '../../../core/cache/isar_service.dart';

final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

// STREAM KASIR - LIMIT 150 BIAR KILAT
final inventoryStreamProvider = StreamProvider<List<BarangData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.barang)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])..limit(150)).watch();
});

// SUPPLIER LIST - FIX: supplier gak ada updatedAt, pakai nama
final supplierListProvider = StreamProvider<List<SupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.supplier)..orderBy([(t) => OrderingTerm.asc(t.nama)])).watch();
});

// STOK MENIPIS - FILTER DI DART
final stokMenipisProvider = Provider<List<BarangData>>((ref) {
  final list = ref.watch(inventoryStreamProvider).value?? [];
  return list.where((b) => b.stok <= b.safetyStock).toList();
});

// INVENTORY CONTROLLER - HPP RUMUS BENAR + FIX refreshCacheAfterCheckout
final inventoryControllerProvider = Provider((ref) {
  final db = ref.watch(localDbProvider);
  return _InventoryController(db);
});

class _InventoryController {
  final LocalDatabase db;
  _InventoryController(this.db);

  Future<void> beli({required int barangId, required int qty, required double harga, bool isSatuanBesar = false, String? supplier, DateTime? tanggal, String? nota}) async {
    await db.transaksiDao.prosesPembelian(
      barangId: barangId,
      qtyInput: qty,
      hargaBeliPerSatuanInput: harga,
      isSatuanBesar: isSatuanBesar,
      supplier: supplier,
      tanggal: tanggal,
      refId: nota,
    );
  }

  // FIX UNTUK kasir_provider.dart line 52 yang error
  Future<void> refreshCacheAfterCheckout(int barangId) async {
    try {
      final barang = await (db.select(db.barang)..where((b) => b.id.equals(barangId))).getSingleOrNull();
      if (barang == null) return;
      // hitung TOR 30 hari pakai 'KELUAR' kutip satu
      final batas = DateTime.now().subtract(const Duration(days: 30));
      final logs = await (db.select(db.kartuStok)
        ..where((tbl) => tbl.barangId.equals(barangId))
        ..where((tbl) => tbl.tipe.equals('KELUAR'))
        ..where((tbl) => tbl.tanggal.isBiggerThanValue(batas))
      ).get();
      final totalKeluar = logs.fold<int>(0, (sum, e) => sum + e.qty.abs());
      final tor = barang.stok == 0 ? 0.0 : totalKeluar / barang.stok;
      
      await IsarService.syncFromDrift(
        barangId: barang.id,
        nama: barang.nama,
        sku: barang.sku?? '',
        stok: barang.stok,
        safetyStock: barang.safetyStock,
        hpp: barang.hppAverage,
        tor: tor.toDouble(),
      );
    } catch (e) {
      // jangan crash kasir kalau isar belum ready
    }
  }
}

// HITUNG KELUAR 30 HARI - FIX pakai 'KELUAR' kutip satu, bukan "KELUAR"
Future<int> hitungKeluar30Hari(LocalDatabase db, int barangId) async {
  final DateTime batas = DateTime.now().subtract(const Duration(days: 30));
  final List<KartuStokData> logs = await (db.select(db.kartuStok)
    ..where((tbl) => tbl.barangId.equals(barangId))
    ..where((tbl) => tbl.tipe.equals('KELUAR'))
    ..where((tbl) => tbl.tanggal.isBiggerThanValue(batas))
  ).get();
  return logs.fold<int>(0, (int sum, KartuStokData e) => sum + e.qty.abs());
}