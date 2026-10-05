import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../../core/services/pelanggan_rating_service.dart';

class PiutangSummary {
  final String namaPelanggan;
  final double totalPiutang; // sisa piutang aktif
  final int jumlahNota;
  final List<PelangganPiutangData> daftarTransaksi;
  final String statusWarna; // HITAM KUNING MERAH MERAH_TUA HIJAU
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

// PROVIDER UTAMA - dipakai PiutangScreen & BukuPiutangScreen
final piutangListProvider = StreamProvider.autoDispose<List<PiutangSummary>>((ref) {
  final db = ref.watch(localDbProvider);

  // ambil semua piutang yang BELUM_LUNAS / CICIL
  return (db.select(db.pelangganPiutang)
   ..where((p) => p.statusBayar.equals('BELUM_LUNAS').or((p) => p.statusBayar.equals('CICIL'))))
 .watch().map((allPiutang) {
    final Map<String, List<PelangganPiutangData>> grouped = {};
    for (var trx in allPiutang) {
      final nama = trx.pelangganNama.isEmpty? 'Pelanggan Umum' : trx.pelangganNama;
      grouped.putIfAbsent(nama, () => []).add(trx);
    }

    final List<PiutangSummary> result = [];
    grouped.forEach((nama, trxs) {
      final total = trxs.fold<double>(0.0, (sum, t) => sum + t.sisaPiutang);
      // warna terparah di grup ini (MERAH_TUA > MERAH > KUNING > HITAM)
      String worstWarna = 'HITAM';
      int maxLewat = -999;
      for (var t in trxs) {
        final w = PelangganRatingService.warnaPiutang(t.jatuhTempo, t.statusBayar);
        final lewat = DateTime.now().difference(t.jatuhTempo).inDays;
        if (lewat > maxLewat) maxLewat = lewat;
        if (w == 'MERAH_TUA') worstWarna = w;
        else if (w == 'MERAH' && worstWarna!= 'MERAH_TUA') worstWarna = w;
        else if (w == 'KUNING' && worstWarna == 'HITAM') worstWarna = w;
      }

      result.add(PiutangSummary(
        namaPelanggan: nama,
        totalPiutang: total,
        jumlahNota: trxs.length,
        daftarTransaksi: trxs,
        statusWarna: worstWarna,
        maxLewatHari: maxLewat,
      ));
    });

    // URUTKAN PRIORITAS TAGIH - skor tertinggi dulu (yang kamu minta)
    result.sort((a, b) {
      final skorA = a.maxLewatHari * 0.7 + a.totalPiutang / 1000000 * 0.3;
      final skorB = b.maxLewatHari * 0.7 + b.totalPiutang / 1000000 * 0.3;
      return skorB.compareTo(skorA);
    });

    return result;
  });
});

// Untuk header grand total
final grandTotalPiutangProvider = Provider<double>((ref) {
  final async = ref.watch(piutangListProvider).valueOrNull?? [];
  return async.fold<double>(0, (sum, g) => sum + g.totalPiutang);
});