import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// Model Ringkasan Piutang per Pelanggan
class PiutangSummary {
  final String namaPelanggan;
  final double totalPiutang;
  final int jumlahNota;
  final List<TransaksiData> daftarTransaksi;

  PiutangSummary({
    required this.namaPelanggan,
    required this.totalPiutang,
    required this.jumlahNota,
    required this.daftarTransaksi,
  });
}

// Stream / Future Provider untuk mengambil daftar piutang aktif
final piutangListProvider = FutureProvider.autoDispose<List<PiutangSummary>>((ref) async {
  final db = ref.watch(localDbProvider);

  // Ambil transaksi yang tipenya 'piutang' atau status bayarnya belum lunas
  final listTransaksi = await (db.select(db.transaksi)
        ..where((t) => t.statusBayar.equals('BELUM_LUNAS')))
      .get();

  // Kelompokkan berdasarkan nama relasi / pelanggan
  final Map<String, List<TransaksiData>> grouped = {};
  for (var trx in listTransaksi) {
    final nama = trx.namaRelasi ?? 'Pelanggan Umum';
    if (!grouped.containsKey(nama)) {
      grouped[nama] = [];
    }
    grouped[nama]!.add(trx);
  }

  // Ubah ke bentuk list summary
  List<PiutangSummary> result = [];
  grouped.forEach((nama, trxs) {
    double total = trxs.fold(0, (sum, t) => sum + t.totalHarga);
    result.add(PiutangSummary(
      namaPelanggan: nama,
      totalPiutang: total,
      jumlahNota: trxs.length,
      daftarTransaksi: trxs,
    ));
  });

  return result;
});
