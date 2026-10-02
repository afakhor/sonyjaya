import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';

// ==========================================
// 1. STATE PROVIDERS UNTUK FILTER & PENCARIAN (TAMBAHAN)
// ==========================================

/// Provider untuk menyimpan kata kunci pencarian log
final logSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider untuk memfilter log berdasarkan ID Barang spesifik (Opsional/Nullable)
final logSelectedBarangIdProvider = StateProvider.autoDispose<int?>((ref) => null);

/// Provider untuk membatasi jumlah baris log yang dimuat agar data tidak berat (Default: 100)
final logLimitProvider = StateProvider.autoDispose<int>((ref) => 100);


// ==========================================
// 2. LOG PROVIDERS UTAMA (EKSISTING & FIX)
// ==========================================

/// 1. Provider Log Kartu Stok
final logStokProvider = StreamProvider.autoDispose<List<KartuStokData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);

  final query = db.select(db.kartuStok)
    ..orderBy([(k) => drift.OrderingTerm(expression: k.tanggal, mode: drift.OrderingMode.desc)])
    ..limit(limit);

  if (barangId != null) {
    query.where((k) => k.barangId.equals(barangId));
  }

  return query.watch();
});

/// 2. Provider Log Penjualan
final logPenjualanProvider = StreamProvider.autoDispose<List<PenjualanData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);

  final query = db.select(db.penjualan)
    ..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])
    ..limit(limit);

  if (barangId != null) {
    query.where((p) => p.barangId.equals(barangId));
  }

  return query.watch();
});

/// 3. Provider Log Pembelian
final logPembelianProvider = StreamProvider.autoDispose<List<PembelianData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);

  final query = db.select(db.pembelian)
    ..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])
    ..limit(limit);

  if (barangId != null) {
    query.where((p) => p.barangId.equals(barangId));
  }

  return query.watch();
});

/// 4. Provider Log Stock Opname
final logOpnameProvider = StreamProvider.autoDispose<List<StockOpnameData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);

  final query = db.select(db.stockOpname)
    ..orderBy([(s) => drift.OrderingTerm(expression: s.tanggal, mode: drift.OrderingMode.desc)])
    ..limit(limit);

  if (barangId != null) {
    query.where((s) => s.barangId.equals(barangId));
  }

  return query.watch();
});

/// 5. Provider Log Purchase Order (PO)
final logPoProvider = StreamProvider.autoDispose<List<PurchaseOrderData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);

  final query = db.select(db.purchaseOrders)
    ..orderBy([(p) => drift.OrderingTerm(expression: p.tanggalBuat, mode: drift.OrderingMode.desc)])
    ..limit(limit);

  return query.watch();
});


// ==========================================
// 3. FILTERED LOG PROVIDERS (TAMBAHAN OPTIMALISASI PENCARIAN)
// ==========================================

/// Filtered Log Penjualan berdasarkan kata kunci pencarian di UI
final filteredLogPenjualanProvider = Provider.autoDispose<AsyncValue<List<PenjualanData>>>((ref) {
  final asyncPenjualan = ref.watch(logPenjualanProvider);
  final query = ref.watch(logSearchQueryProvider).toLowerCase();

  return asyncPenjualan.whenData((list) {
    if (query.isEmpty) return list;
    return list.where((item) => 
      item.id.toString().contains(query) || 
      item.tipe.toLowerCase().contains(query)
    ).toList();
  });
});

/// Filtered Log PO berdasarkan Nomor PO atau Nama Relasi
final filteredLogPoProvider = Provider.autoDispose<AsyncValue<List<PurchaseOrderData>>>((ref) {
  final asyncPo = ref.watch(logPoProvider);
  final query = ref.watch(logSearchQueryProvider).toLowerCase();

  return asyncPo.whenData((list) {
    if (query.isEmpty) return list;
    return list.where((po) => 
      po.noPo.toLowerCase().contains(query) || 
      po.namaRelasi.toLowerCase().contains(query) ||
      po.statusPo.toLowerCase().contains(query)
    ).toList();
  });
});
