import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../../core/services/pelanggan_rating_service.dart';

class PiutangSummary {
  final String namaPelanggan;
  final double totalPiutang;
  final int jumlahNota;
  final List<PelangganPiutangData> daftarTransaksi;
  final String statusWarna;
  final int maxLewatHari;
  PiutangSummary({
    required this.namaPelanggan,
    required this.totalPiutang,
    required this.jumlahNota,
    required this.daftarTransaksi,
    required this.statusWarna,
    required this.maxLewatHari,
  });
}

final piutangListProvider = StreamProvider.autoDispose<List<PiutangSummary>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.pelangganPiutang)
    ..where((p) => p.statusBayar.isIn(['BELUM_LUNAS', 'CICIL'])))
      .watch().map((allPiutang) {
    final Map<String, List<PelangganPiutangData>> grouped = {};
    for (var trx in allPiutang) {
      final nama = trx.pelangganNama.isEmpty ? 'Pelanggan Umum' : trx.pelangganNama;
      grouped.putIfAbsent(nama, () => []).add(trx);
    }
    final result = <PiutangSummary>[];
    grouped.forEach((nama, trxs) {
      final total = trxs.fold<double>(0, (s, t) => s + t.sisaPiutang);
      String worst = 'HITAM';
      int maxLewat = -999;
      for (var t in trxs) {
        final w = PelangganRatingService.warnaPiutang(t.jatuhTempo, t.statusBayar);
        final lewat = DateTime.now().difference(t.jatuhTempo).inDays;
        if (lewat > maxLewat) maxLewat = lewat;
        if (w == 'MERAH_TUA') worst = w;
        else if (w == 'MERAH' && worst != 'MERAH_TUA') worst = w;
        else if (w == 'KUNING' && worst == 'HITAM') worst = w;
      }
      result.add(PiutangSummary(
        namaPelanggan: nama,
        totalPiutang: total,
        jumlahNota: trxs.length,
        daftarTransaksi: trxs,
        statusWarna: worst,
        maxLewatHari: maxLewat,
      ));
    });
    result.sort((a, b) {
      final skorA = a.maxLewatHari * 0.7 + a.totalPiutang / 1e6 * 0.3;
      final skorB = b.maxLewatHari * 0.7 + b.totalPiutang / 1e6 * 0.3;
      return skorB.compareTo(skorA);
    });
    return result;
  });
});
