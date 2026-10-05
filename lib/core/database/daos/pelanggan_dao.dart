import 'package:drift/drift.dart';
import '../local_database.dart';
part 'pelanggan_dao.g.dart';

@DriftAccessor(tables: [PelangganMaster,PelangganPiutang])
class PelangganMasterDao extends DatabaseAccessor<LocalDatabase> with _$PelangganMasterDaoMixin {
  PelangganMasterDao(super.db);

  Stream<List<PelangganMasterData>> watchAll() => (select(pelangganMaster)..orderBy([(p)=> OrderingTerm.desc(p.skorRating)])).watch();

  Future<void> upsertAndRating({required String nama, required double tambahBelanja, required int tambahVariasi, required int tambahQty}) async {
    final existing = await (select(pelangganMaster)..where((p)=>p.nama.equals(nama))).getSingleOrNull();
    if(existing==null){
      final rating = _hitungRating(0+tambahBelanja, 1, tambahVariasi, tambahQty, 0, 0);
      await into(pelangganMaster).insert(PelangganMasterCompanion.insert(nama: nama, totalBelanja: Value(tambahBelanja), frekuensi: Value(1), variasiBarang: Value(tambahVariasi), totalQty: Value(tambahQty), skorRating: Value(rating['skor']), status: Value(rating['status']), lastBeli: Value(DateTime.now())));
    } else {
      final newTotal = existing.totalBelanja + tambahBelanja;
      final newFreq = existing.frekuensi + 1;
      final newVar = existing.variasiBarang + tambahVariasi;
      final newQty = existing.totalQty + tambahQty;
      final rating = _hitungRating(newTotal, newFreq, newVar, newQty, 0, existing.totalPiutangAktif);
      await (update(pelangganMaster)..where((p)=>p.nama.equals(nama))).write(PelangganMasterCompanion(totalBelanja: Value(newTotal), frekuensi: Value(newFreq), variasiBarang: Value(newVar), totalQty: Value(newQty), skorRating: Value(rating['skor']), status: Value(rating['status']), lastBeli: Value(DateTime.now())));
    }
  }

  Map<String,dynamic> _hitungRating(double total, int freq, int variasi, int qty, int hariSejak, double piutangAktif){
    double skor = 0;
    skor += (total/2000000).clamp(0,10)*0.4;
    skor += (freq/20).clamp(0,10)*0.3;
    skor += (variasi/15).clamp(0,10)*0.15;
    skor += (qty/200).clamp(0,10)*0.15;
    if(piutangAktif>1000000 && hariSejak>60) skor-=3;
    String status;
    if(piutangAktif>1000000 && hariSejak>60) status='BADDEBT';
    else if(skor>=7.5) status='TETAP';
    else if(skor>=4) status='PELANGGAN';
    else status='PEMBELI';
    return {'skor':skor.clamp(0,10).toDouble(),'status':status};
  }
}