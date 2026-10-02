import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sony_jaya/core/database/local_database.dart';
import 'package:sony_jaya/features/inventory/providers/inventory_provider.dart';

// Model Ringkasan Piutang per Pelanggan
class PiutangSummary {
  final String namaPelanggan;
  final double totalPiutang;
  final int jumlahNota;
  final List<PenjualanData> daftarTransaksi;

  PiutangSummary({
    required this.namaPelanggan,
    required this.totalPiutang,
    required this.jumlahNota,
    required this.daftarTransaksi,
  });
}

// Provider untuk mengambil daftar piutang aktif
final piutangListProvider = FutureProvider.autoDispose<List<PiutangSummary>>((ref) async {
  final db = ref.watch(localDbProvider);

  // Filter transaksi penjualan bertipe 'piutang'
  final listTransaksi = await (db.select(db.penjualan)
        ..where((t) => t.tipe.equals('piutang')))
      .get();

  final Map<String, List<PenjualanData>> grouped = {};
  for (var trx in listTransaksi) {
    const String nama = 'Pelanggan Umum';
    if (!grouped.containsKey(nama)) {
      grouped[nama] = [];
    }
    grouped[nama]!.add(trx);
  }

  final List<PiutangSummary> result = [];
  grouped.forEach((nama, trxs) {
    final double total = trxs.fold<double>(
      0.0,
      (sum, t) => sum + (t.qtyPcs * t.hargaJualPerPcs),
    );
    result.add(PiutangSummary(
      namaPelanggan: nama,
      totalPiutang: total,
      jumlahNota: trxs.length,
      daftarTransaksi: trxs,
    ));
  });

  return result;
});
