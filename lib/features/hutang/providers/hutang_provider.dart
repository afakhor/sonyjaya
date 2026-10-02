import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sony_jaya/core/database/local_database.dart';
import 'package:sony_jaya/features/inventory/providers/inventory_provider.dart';

// Model Ringkasan Hutang ke Supplier
class HutangSummary {
  final String namaSupplier;
  final double totalHutang;
  final int jumlahPo;
  final List<PurchaseOrders> daftarPo;

  HutangSummary({
    required this.namaSupplier,
    required this.totalHutang,
    required this.jumlahPo,
    required this.daftarPo,
  });
}

// Provider untuk mengambil daftar PO dari supplier yang belum lunas
final hutangListProvider = FutureProvider.autoDispose<List<HutangSummary>>((ref) async {
  final db = ref.watch(localDbProvider);

  // Ambil PO tipe VENDOR dengan status bayar BELUM_LUNAS
  final listPo = await (db.select(db.purchaseOrders)
        ..where((p) => p.tipePo.equals('VENDOR') & p.statusBayar.equals('BELUM_LUNAS')))
      .get();

  final Map<String, List<PurchaseOrdersData>> grouped = {};
  for (var po in listPo) {
    final String nama = po.namaRelasi.isNotEmpty ? po.namaRelasi : 'Supplier Umum';
    if (!grouped.containsKey(nama)) {
      grouped[nama] = [];
    }
    grouped[nama]!.add(po);
  }

  final List<HutangSummary> result = [];
  grouped.forEach((nama, pos) {
    final double total = pos.fold<double>(
      0.0,
      (sum, p) => sum + p.totalKeseluruhan,
    );
    result.add(HutangSummary(
      namaSupplier: nama,
      totalHutang: total,
      jumlahPo: pos.length,
      daftarPo: pos,
    ));
  });

  return result;
});
