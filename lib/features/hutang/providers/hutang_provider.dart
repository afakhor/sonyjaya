// lib/features/hutang/providers/hutang_provider.dart - FINAL FIX
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

class HutangGroup {
  final String namaSupplier;
  final int jumlahPo;
  final double totalHutang;
  final List<PurchaseOrdersData> daftarPo;
  HutangGroup({required this.namaSupplier, required this.jumlahPo, required this.totalHutang, required this.daftarPo});
}

// Provider lama PO-based tetap biar tidak error
final hutangListProvider = StreamProvider<List<HutangGroup>>((ref) async* {
  final db = ref.watch(localDbProvider);
  final poList = await (db.select(db.purchaseOrders)..where((t) => t.statusBayar.equals('BELUM_LUNAS'))).get();
  final Map<String, List<PurchaseOrdersData>> grouped = {};
  for (var po in poList) {
    grouped.putIfAbsent(po.namaRelasi, () => []).add(po);
  }
  final result = grouped.entries.map((e) {
    final total = e.value.fold<double>(0, (s, po) => s + po.totalKeseluruhan);
    return HutangGroup(namaSupplier: e.key, jumlahPo: e.value.length, totalHutang: total, daftarPo: e.value);
  }).toList();
  yield result;
});

// Provider baru Nota-based kuning sinkron
final hutangSupplierListProvider = StreamProvider<List<HutangSupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.hutangDao.watchAll();
});
