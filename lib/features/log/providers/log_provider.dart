import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'log_provider.g.dart';

@riverpod class LogSearchQuery extends _$LogSearchQuery { @override String build() => ''; void set(String v) => state = v; }
@riverpod class LogSelectedBarangId extends _$LogSelectedBarangId { @override int? build() => null; void set(int? v) => state = v; }
@riverpod class LogLimit extends _$LogLimit { @override int build() => 200; void set(int v) => state = v; }

class DateRange { DateTime? start; DateTime? end; DateRange(this.start, this.end); }
@riverpod class LogDateRange extends _$LogDateRange { @override DateRange build() => DateRange(null, null); void setRange(DateTime? s, DateTime? e) => state = DateRange(s, e); void clear() => state = DateRange(null, null); }

// STOK - CCTV BASE
final logStokProvider = StreamProvider.autoDispose<List<KartuStokData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);
  final range = ref.watch(logDateRangeProvider);
  final q = db.select(db.kartuStok)..orderBy([(k) => drift.OrderingTerm(expression: k.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId != null) q.where((k) => k.barangId.equals(barangId));
  if (range.start != null) q.where((k) => k.tanggal.isBiggerOrEqualValue(range.start!));
  if (range.end != null) q.where((k) => k.tanggal.isSmallerOrEqualValue(range.end!.add(const Duration(days: 1))));
  return q.watch();
});

final logPembelianProvider = StreamProvider.autoDispose<List<PembelianData>>((ref) {
  final db = ref.watch(localDbProvider); final limit = ref.watch(logLimitProvider); final barangId = ref.watch(logSelectedBarangIdProvider); final range = ref.watch(logDateRangeProvider);
  final q = db.select(db.pembelian)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId != null) q.where((p) => p.barangId.equals(barangId));
  if (range.start != null) q.where((p) => p.tanggal.isBiggerOrEqualValue(range.start!));
  if (range.end != null) q.where((p) => p.tanggal.isSmallerOrEqualValue(range.end!.add(const Duration(days: 1))));
  return q.watch();
});

final logPenjualanProvider = StreamProvider.autoDispose<List<PenjualanData>>((ref) {
  final db = ref.watch(localDbProvider); final limit = ref.watch(logLimitProvider); final barangId = ref.watch(logSelectedBarangIdProvider); final range = ref.watch(logDateRangeProvider);
  final q = db.select(db.penjualan)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId != null) q.where((p) => p.barangId.equals(barangId));
  if (range.start != null) q.where((p) => p.tanggal.isBiggerOrEqualValue(range.start!));
  if (range.end != null) q.where((p) => p.tanggal.isSmallerOrEqualValue(range.end!.add(const Duration(days: 1))));
  return q.watch();
});

final logOpnameProvider = StreamProvider.autoDispose<List<StockOpnameData>>((ref) {
  final db = ref.watch(localDbProvider); final limit = ref.watch(logLimitProvider); final barangId = ref.watch(logSelectedBarangIdProvider); final range = ref.watch(logDateRangeProvider);
  final q = db.select(db.stockOpname)..orderBy([(s) => drift.OrderingTerm(expression: s.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId != null) q.where((s) => s.barangId.equals(barangId));
  if (range.start != null) q.where((s) => s.tanggal.isBiggerOrEqualValue(range.start!));
  if (range.end != null) q.where((s) => s.tanggal.isSmallerOrEqualValue(range.end!.add(const Duration(days: 1))));
  return q.watch();
});

final logPoProvider = StreamProvider.autoDispose<List<PurchaseOrder>>((ref) {
  final db = ref.watch(localDbProvider); final limit = ref.watch(logLimitProvider); final range = ref.watch(logDateRangeProvider);
  final q = db.select(db.purchaseOrders)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggalPo, mode: drift.OrderingMode.desc)])..limit(limit);
  if (range.start != null) q.where((p) => p.tanggalPo.isBiggerOrEqualValue(range.start!));
  if (range.end != null) q.where((p) => p.tanggalPo.isSmallerOrEqualValue(range.end!.add(const Duration(days: 1))));
  return q.watch();
});

// CCTV GABUNGAN + LABA
final cctvLogProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final stok = await ref.watch(logStokProvider.future);
  final beli = await ref.watch(logPembelianProvider.future);
  final jual = await ref.watch(logPenjualanProvider.future);
  final opname = await ref.watch(logOpnameProvider.future);
  List<Map<String, dynamic>> all = [];
  for (var s in stok) all.add({'tanggal': s.tanggal, 'tipe': s.tipe, 'qty': s.qty, 'stokAkhir': s.stokAkhir, 'hpp': s.hargaBeliSaatItu, 'ref': s.refId, 'barangId': s.barangId});
  for (var b in beli) all.add({'tanggal': b.tanggal, 'tipe': 'PEMBELIAN', 'qty': b.qtyPcs, 'hpp': b.hargaBeliPerPcs, 'ref': b.supplier, 'barangId': b.barangId});
  for (var j in jual) all.add({'tanggal': j.tanggal, 'tipe': 'PENJUALAN', 'qty': -j.qtyPcs, 'hpp': j.hppSnapshot, 'laba': j.laba, 'ref': j.tipe, 'barangId': j.barangId});
  for (var o in opname) all.add({'tanggal': o.tanggal, 'tipe': 'OPNAME ${o.selisih>0?"+":""}${o.selisih}', 'qty': o.selisih, 'stokAkhir': o.stokFisik, 'ref': o.keterangan, 'barangId': o.barangId});
  all.sort((a,b)=> (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime));
  return all;
});

final labaPeriodeProvider = FutureProvider.autoDispose<double>((ref) async {
  final jual = await ref.watch(logPenjualanProvider.future);
  return jual.fold<double>(0, (sum, e) => sum + e.laba);
});