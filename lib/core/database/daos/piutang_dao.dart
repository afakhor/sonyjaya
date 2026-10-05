import 'package:drift/drift.dart';
import '../local_database.dart';
part 'piutang_dao.g.dart';

@DriftAccessor(tables: [PelangganPiutang,PembayaranPiutang,PelangganMaster])
class PiutangDao extends DatabaseAccessor<LocalDatabase> with _$PiutangDaoMixin {
  PiutangDao(super.db);

  Future<void> createPiutang({int? penjualanId, required String pelangganNama, required double total, required int topDays, required DateTime jatuhTempo, String? keterangan, String noNota=''}) async {
    await into(pelangganPiutang).insert(PelangganPiutangCompanion.insert(noNota: noNota.isEmpty? 'NOTA-${DateTime.now().millisecondsSinceEpoch}' : noNota, pelangganNama: pelangganNama, totalTagihan: total, sisaPiutang: total, topDays: Value(topDays), tanggalNota: Value(DateTime.now()), jatuhTempo: jatuhTempo, keterangan: Value(keterangan)));
    final aktif = await _getPiutangAktif(pelangganNama);
    await (update(pelangganMaster)..where((p)=>p.nama.equals(pelangganNama))).write(PelangganMasterCompanion(totalPiutangAktif: Value(aktif)));
  }

  Future<double> _getPiutangAktif(String nama) async {
    // FIX: pakai | bukan .or()
    final list = await (select(pelangganPiutang)..where((p)=>p.pelangganNama.equals(nama))..where((p)=> p.statusBayar.equals('BELUM_LUNAS') | p.statusBayar.equals('CICIL'))).get();
    return list.fold<double>(0,(s,e)=> s+e.sisaPiutang);
  }

  Future<void> bayarCicil(int piutangId, double jumlah, DateTime tgl, {String metode='TRANSFER'}) async {
    await transaction(() async {
      final p = await (select(pelangganPiutang)..where((pp)=>pp.id.equals(piutangId))).getSingle();
      final newDibayar = p.totalDibayar + jumlah;
      final newSisa = p.totalTagihan - newDibayar;
      final lunas = newSisa <= 100;
      await into(pembayaranPiutang).insert(PembayaranPiutangCompanion.insert(piutangId: piutangId, jumlahBayar: jumlah, tanggalBayar: Value(tgl), metode: Value(metode), catatan: Value(lunas?'LUNAS':'CICIL ${tgl.toString().substring(0,10)}')));
      await (update(pelangganPiutang)..where((pp)=>pp.id.equals(piutangId))).write(PelangganPiutangCompanion(totalDibayar: Value(newDibayar), sisaPiutang: Value(lunas?0:newSisa), statusBayar: Value(lunas?'LUNAS':'CICIL'), tanggalLunas: lunas? Value(tgl) : const Value.absent()));
      final aktif = await _getPiutangAktif(p.pelangganNama);
      await (update(pelangganMaster)..where((pm)=>pm.nama.equals(p.pelangganNama))).write(PelangganMasterCompanion(totalPiutangAktif: Value(aktif)));
    });
  }

  Stream<List<PelangganPiutangData>> watchPrioritasTagih() => (select(pelangganPiutang)..where((p)=> p.statusBayar.equals('BELUM_LUNAS') | p.statusBayar.equals('CICIL'))).watch().map((list){
    list.sort((a,b){
      final lewatA = DateTime.now().difference(a.jatuhTempo).inDays;
      final lewatB = DateTime.now().difference(b.jatuhTempo).inDays;
      final skorA = lewatA*0.7 + a.sisaPiutang/1e6*0.3;
      final skorB = lewatB*0.7 + b.sisaPiutang/1e6*0.3;
      return skorB.compareTo(skorA);
    });
    return list;
  });
}