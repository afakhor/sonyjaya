import 'package:drift/drift.dart';
import '../local_database.dart';
part 'pelanggan_dao.g.dart';

@DriftAccessor(tables: [PelangganMaster])
class PelangganMasterDao extends DatabaseAccessor<LocalDatabase> with _$PelangganMasterDaoMixin {
  PelangganMasterDao(super.db);

  Future<void> upsertAndRating({required String nama, required double tambahBelanja, required int tambahVariasi, required int tambahQty}) async {
    final existing = await (select(pelangganMaster)..where((p)=>p.nama.equals(nama))).getSingleOrNull();
    if(existing==null){
      await into(pelangganMaster).insert(PelangganMasterCompanion.insert(
        nama: nama,
        totalBelanja: Value(tambahBelanja),
        frekuensi: Value(1),
        variasiBarang: Value(tambahVariasi),
        totalQty: Value(tambahQty),
        skorRating: Value(1.0),
        status: Value('PEMBELI'),
        lastBeli: Value(DateTime.now()),
      ));
    } else {
      final newFreq = existing.frekuensi + 1;
      final newBelanja = existing.totalBelanja + tambahBelanja;
      final newVariasi = existing.variasiBarang + tambahVariasi;
      final newQty = existing.totalQty + tambahQty;
      // rumus rating: frekuensi*0.4 + variasi*0.3 + belanja/1jt*0.3
      final skor = newFreq*0.4 + newVariasi*0.3 + newBelanja/1000000*0.3;
      String status = 'PEMBELI';
      if(newFreq>=3 && newBelanja>=500000) status='PELANGGAN';
      if(newFreq>=10 && newBelanja>=2000000) status='TETAP';
      if(existing.totalPiutangAktif>0){
        // kalau ada piutang lewat 60 hari jadi BADDEBT
        final piutangLewat = await (select(db.pelangganPiutang)..where((p)=>p.pelangganNama.equals(nama))..where((p)=>p.statusBayar.isIn(['BELUM_LUNAS','CICIL']))..where((p)=>p.jatuhTempo.isSmallerThanValue(DateTime.now().subtract(const Duration(days:60))))).get();
        if(piutangLewat.isNotEmpty) status='BADDEBT';
      }
      await (update(pelangganMaster)..where((p)=>p.nama.equals(nama))).write(PelangganMasterCompanion(
        totalBelanja: Value(newBelanja),
        frekuensi: Value(newFreq),
        variasiBarang: Value(newVariasi),
        totalQty: Value(newQty),
        skorRating: Value(skor),
        status: Value(status),
        lastBeli: Value(DateTime.now()),
      ));
    }
  }

  Stream<List<PelangganMasterData>> watchAll() => (select(pelangganMaster)..orderBy([(t)=> OrderingTerm.desc(t.skorRating)])).watch();
}
