import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'log_provider.g.dart';

@riverpod
class LogSearchQuery extends _$LogSearchQuery {
  @override String build() => '';
  void set(String v) => state = v;
}
@riverpod
class LogSelectedBarangId extends _$LogSelectedBarangId {
  @override int? build() => null;
  void set(int? v) => state = v;
}
@riverpod
class LogLimit extends _$LogLimit {
  @override int build() => 100;
  void set(int v) => state = v;
}

final logStokProvider = StreamProvider.autoDispose<List<KartuStokData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);
  final query = db.select(db.kartuStok)..orderBy([(k) => drift.OrderingTerm(expression: k.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId!= null) query.where((k) => k.barangId.equals(barangId));
  return query.watch();
});

final logPenjualanProvider = StreamProvider.autoDispose<List<PenjualanData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);
  final query = db.select(db.penjualan)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId!= null) query.where((p) => p.barangId.equals(barangId));
  return query.watch();
});

final logPembelianProvider = StreamProvider.autoDispose<List<PembelianData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);
  final query = db.select(db.pembelian)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId!= null) query.where((p) => p.barangId.equals(barangId));
  return query.watch();
});

final logOpnameProvider = StreamProvider.autoDispose<List<StockOpnameData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final barangId = ref.watch(logSelectedBarangIdProvider);
  final query = db.select(db.stockOpname)..orderBy([(s) => drift.OrderingTerm(expression: s.tanggal, mode: drift.OrderingMode.desc)])..limit(limit);
  if (barangId!= null) query.where((s) => s.barangId.equals(barangId));
  return query.watch();
});

final logPoProvider = StreamProvider.autoDispose<List<PurchaseOrdersData>>((ref) {
  final db = ref.watch(localDbProvider);
  final limit = ref.watch(logLimitProvider);
  final query = db.select(db.purchaseOrders)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggalPo, mode: drift.OrderingMode.desc)])..limit(limit);
  return query.watch();
});