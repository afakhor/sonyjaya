import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';

// Gunakan provider database yang sudah ada di proyek Anda
// (Sama seperti yang dipakai di kasir_provider.dart)

final logStokProvider = StreamProvider.autoDispose<List<KartuStokData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.kartuStok)
        ..orderBy([(k) => drift.OrderingTerm(expression: k.tanggal, mode: drift.OrderingMode.desc)]))
      .watch();
});

final logPenjualanProvider = StreamProvider.autoDispose<List<PenjualanData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.penjualan)
        ..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)]))
      .watch();
});

final logPembelianProvider = StreamProvider.autoDispose<List<PembelianData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.pembelian)
        ..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)]))
      .watch();
});

final logOpnameProvider = StreamProvider.autoDispose<List<StockOpnameData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.stockOpname)
        ..orderBy([(s) => drift.OrderingTerm(expression: s.tanggal, mode: drift.OrderingMode.desc)]))
      .watch();
});

final logPoProvider = StreamProvider.autoDispose<List<PurchaseOrderData>>((ref) {
  final db = ref.watch(localDbProvider);
  // Catatan: Pastikan kolom di tabel PO Anda benar bernama 'tanggalBuat' atau 'tanggal'
  return (db.select(db.purchaseOrders)
        ..orderBy([(p) => drift.OrderingTerm(expression: p.tanggalBuat, mode: drift.OrderingMode.desc)]))
      .watch();
});
