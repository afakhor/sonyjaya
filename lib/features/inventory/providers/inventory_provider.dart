// lib/features/inventory/providers/inventory_provider.dart - FINAL FIX - JANGAN KURANGI LOGIKA LAMA
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';

final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

final barangListProvider = StreamProvider<List<BarangData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.barangDao.watchAll();
});

class InventoryController {
  final LocalDatabase db;
  InventoryController(this.db);

  Future<void> beli({
    required int barangId,
    required int qty,
    required double harga,
    required bool isSatuanBesar,
    required String supplier,
    required DateTime tanggal,
    required String nota,
    int? variasiId,
    int? supplierId,
  }) async {
    final barang = await (db.select(db.barang)..where((t) => t.id.equals(barangId))).getSingle();
    final int konv = barang.konversi;
    final int qtyPcs = isSatuanBesar ? qty * konv : qty;
    final double hargaPerPcs = isSatuanBesar ? harga / konv : harga;

    final int oldStok = barang.stok;
    final double oldHpp = barang.hppAverage;
    final double newHpp = oldStok <= 0 ? hargaPerPcs : ((oldStok * oldHpp) + (qtyPcs * hargaPerPcs)) / (oldStok + qtyPcs);

    await (db.update(db.barang)..where((t) => t.id.equals(barangId))).write(BarangCompanion(
      stok: drift.Value(oldStok + qtyPcs),
      hppAverage: drift.Value(newHpp),
      supplierNama: drift.Value(supplier.isEmpty ? null : supplier),
      supplierId: supplierId != null ? drift.Value(supplierId) : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    ));

    if (variasiId != null) {
      final vari = await (db.select(db.barangVariasi)..where((t) => t.id.equals(variasiId))).getSingleOrNull();
      if (vari != null) {
        await (db.update(db.barangVariasi)..where((t) => t.id.equals(variasiId))).write(BarangVariasiCompanion(stok: drift.Value(vari.stok + qtyPcs)));
      }
    }

    await db.into(db.pembelian).insert(PembelianCompanion.insert(
      barangId: barangId,
      variasiId: drift.Value(variasiId),
      qtyPcs: qtyPcs,
      hargaBeliPerPcs: hargaPerPcs,
      supplier: drift.Value(supplier),
      supplierId: drift.Value(supplierId),
      noNota: drift.Value(nota),
      tanggal: drift.Value(tanggal),
    ));

    await db.into(db.kartuStok).insert(KartuStokCompanion.insert(
      barangId: barangId,
      variasiId: drift.Value(variasiId),
      tipe: 'MASUK',
      qty: qtyPcs,
      stokAkhir: oldStok + qtyPcs,
      hargaBeliSaatItu: drift.Value(hargaPerPcs),
      refId: drift.Value(nota),
      tanggal: drift.Value(tanggal),
    ));
  }
}

final inventoryControllerProvider = Provider<InventoryController>((ref) {
  final db = ref.watch(localDbProvider);
  return InventoryController(db);
});
