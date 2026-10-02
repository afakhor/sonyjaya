import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// Model Ringkasan Hutang ke Supplier
class HutangSummary {
  final String namaSupplier;
  final double totalHutang;
  final int jumlahPo;
  final List<PurchaseOrderData> daftarPo;

  HutangSummary({
    required this.namaSupplier,
    required this.totalHutang,
    required this.jumlahPo,
    required this.daftarPo,
  });
}

// Provider untuk mengambil daftar PO / Pembelian dari supplier yang belum lunas
final hutangListProvider = FutureProvider.autoDispose<List<HutangSummary>>((ref) async {
  final db = ref.watch(localDbProvider);

  // Ambil PO tipe VENDOR yang status PO-nya BELUM_LUNAS
  // Menggunakan statusPo dan tanda kurung eksplisit untuk presedensi operator Drift &
  final listPo = await (db.select(db.purchaseOrders)
        ..where((p) => (p.tipePo.equals('VENDOR')) & (p.statusPo.equals('BELUM_LUNAS'))))
      .get();

  // Kelompokkan berdasarkan nama relasi / supplier
  final Map<String, List<PurchaseOrderData>> grouped = {};
  for (var po in listPo) {
    final String nama = po.namaRelasi.isNotEmpty ? po.namaRelasi : 'Supplier Umum';
    if (!grouped.containsKey(nama)) {
      grouped[nama] = [];
    }
    grouped[nama]!.add(po);
  }

  final List<HutangSummary> result = [];
  grouped.forEach((nama, pos) {
    // Presisi kalkulasi bertipe double dengan .fold<double>(0.0, ...)
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
