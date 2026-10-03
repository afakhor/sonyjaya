import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/local_database.dart';

final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

// STREAM KASIR - LIMIT 100 BIAR KILAT, JANGAN LOAD 1000 SEKALIGUS
final inventoryStreamProvider = StreamProvider<List<BarangData>>((ref) {
  final db = ref.watch(localDbProvider);
  // cuma watch 150 terbaru, bukan full table
  return (db.select(db.barang)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])..limit(150)).watch();
});

// SUPPLIER LIST
final supplierListProvider = StreamProvider<List<SupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.supplier)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
});

// STOK MENIPIS - FILTER DI DART, BUKAN SQL BERAT
final stokMenipisProvider = Provider<List<BarangData>>((ref) {
  final list = ref.watch(inventoryStreamProvider).value?? [];
  return list.where((b) => b.stok <= b.safetyStock).toList();
});

// INVENTORY CONTROLLER - HPP RUMUS BENAR
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
}

// HITUNG KELUAR 30 HARI - FIX KELUAR PAKAI 'KELUAR' BUKAN "KELUAR"
// Ini yang bikin error di navigasi Stok
Future<int> hitungKeluar30Hari(LocalDatabase db, int barangId) async {
  final DateTime batas = DateTime.now().subtract(const Duration(days: 30));
  final List<KartuStokData> logs = await (db.select(db.kartuStok)
   ..where((tbl) => tbl.barangId.equals(barangId))
   ..where((tbl) => tbl.tipe.equals('KELUAR')) // kutip satu, aman
   ..where((tbl) => tbl.tanggal.isBiggerThanValue(batas))
  ).get();
  return logs.fold<int>(0, (int sum, KartuStokData e) => sum + e.qty.abs());
}