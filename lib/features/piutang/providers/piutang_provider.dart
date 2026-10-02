import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// Model Ringkasan Piutang per Pelanggan (Menggunakan PenjualanData buatan Drift)
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

  // Mengakses tabel db.penjualan dan memfilter transaksi bertipe 'piutang'
  final listTransaksi = await (db.select(db.penjualan)
        ..where((t) => t.tipe.equals('piutang')))
      .get();

  // Kelompokkan berdasarkan pelanggan
  final Map<String, List<PenjualanData>> grouped = {};
  for (var trx in listTransaksi) {
    const String nama = 'Pelanggan Umum';
    if (!grouped.containsKey(nama)) {
      grouped[nama] = [];
    }
    grouped[nama]!.add(trx);
  }

  // Akumulasi total piutang berdasarkan perkalian qtyPcs * hargaJualPerSatuanSnapshot
  final List<PiutangSummary> result = [];
  grouped.forEach((nama, trxs) {
    final double total = trxs.fold<double>(
      0.0,
      (sum, t) => sum + (t.qtyPcs * t.hargaJualPerSatuanSnapshot),
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
