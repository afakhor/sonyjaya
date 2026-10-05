import 'package:drift/drift.dart';
import '../local_database.dart';
part 'transaksi_dao.g.dart';

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok, StockOpname])
class TransaksiDao extends DatabaseAccessor<LocalDatabase> with _$TransaksiDaoMixin {
  TransaksiDao(super.db);

  Future<void> prosesPembelian({required int barangId, required int qtyInput, required double hargaBeliPerSatuanInput, bool isSatuanBesar=false, String? supplier, DateTime? tanggal, String? refId}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b)=>b.id.equals(barangId))).getSingle();
      final tgl = tanggal??DateTime.now();
      final int mult = isSatuanBesar?barang.konversi:1;
      final int qtyPcs = qtyInput*mult;
      final double hargaPerPcs = isSatuanBesar? (hargaBeliPerSatuanInput/mult) : hargaBeliPerSatuanInput;
      final double hppBaru = barang.stok<=0? hargaPerPcs : ((barang.stok*barang.hppAverage)+(qtyPcs*hargaPerPcs))/(barang.stok+qtyPcs);
      await (update(db.barang)..where((b)=>b.id.equals(barangId))).write(BarangCompanion(stok: Value(barang.stok+qtyPcs), hppAverage: Value(hppBaru), updatedAt: Value(tgl)));
      final idBeli = await into(db.pembelian).insert(PembelianCompanion.insert(barangId: barangId, qtyPcs: qtyPcs, hargaBeliPerPcs: hargaPerPcs, supplier: Value(supplier), tanggal: Value(tgl)));
      await into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: 'MASUK', qty: qtyPcs, qtySisaLog: Value(qtyPcs), stokAkhir: barang.stok+qtyPcs, hargaBeliSaatItu: Value(hargaPerPcs), refId: Value(refId??'BELI-$idBeli'), tanggal: Value(tgl)));
    });
  }

  Future<void> koreksiHppTanpaBeli({required int barangId, required double hppBaru, required String keterangan, DateTime? tanggal}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b)=>b.id.equals(barangId))).getSingle();
      final tgl = tanggal??DateTime.now();
      await into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: 'KOREKSI_HPP', qty: 0, stokAkhir: barang.stok, hargaBeliSaatItu: Value(hppBaru), refId: Value(keterangan), tanggal: Value(tgl)));
      await (update(db.barang)..where((b)=>b.id.equals(barangId))).write(BarangCompanion(hppAverage: Value(hppBaru), updatedAt: Value(tgl)));
    });
  }

  Future<void> prosesPenjualan({required int barangId, required int qtyInput, required double hargaJualPerSatuanInput, bool isSatuanBesar=false, String tipe='ecer'}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b)=>b.id.equals(barangId))).getSingle();
      final int mult = isSatuanBesar?barang.konversi:1;
      final int qtyPcs = qtyInput*mult;
      final double hargaPerPcs = isSatuanBesar? (hargaJualPerSatuanInput/mult) : hargaJualPerSatuanInput;
      if(barang.stok<qtyPcs) throw Exception('STOK MINUS sisa ${barang.stok}');
      if(hargaPerPcs<barang.hppAverage) throw Exception('MARGIN GUARD');
      int sisa = qtyPcs;
      final logs = await (select(db.kartuStok)..where((k)=>k.barangId.equals(barangId))..where((k)=>k.tipe.equals('MASUK'))..where((k)=>k.qtySisaLog.isBiggerThanValue(0))..orderBy([(k)=>OrderingTerm.asc(k.tanggal)])).get();
      for(final l in logs){
        if(sisa<=0) break;
        final ambil=sisa>l.qtySisaLog?l.qtySisaLog:sisa;
        await (update(db.kartuStok)..where((k)=>k.id.equals(l.id))).write(KartuStokCompanion(qtySisaLog: Value(l.qtySisaLog-ambil)));
        sisa-=ambil;
      }
      final stokBaru = barang.stok-qtyPcs;
      final laba = (hargaJualPerSatuanInput*qtyInput)-(barang.hppAverage*qtyPcs);
      await (update(db.barang)..where((b)=>b.id.equals(barangId))).write(BarangCompanion(stok: Value(stokBaru), updatedAt: Value(DateTime.now())));
      final idJual = await into(db.penjualan).insert(PenjualanCompanion.insert(barangId: barangId, qtyPcs: qtyPcs, hargaJualPerPcs: hargaPerPcs, hppSnapshot: Value(barang.hppAverage), laba: Value(laba), tipe: Value(tipe)));
      await into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: 'KELUAR', qty: -qtyPcs, stokAkhir: stokBaru, refId: Value('JUAL-$idJual')));
    });
  }

  Future<int> getTotalKeluar30Hari(int barangId) async {
    final r = await customSelect("SELECT SUM(ABS(qty)) as total FROM kartu_stok WHERE barang_id =? AND tipe = 'KELUAR' AND tanggal >?", variables: [Variable.withInt(barangId), Variable.withDateTime(DateTime.now().subtract(const Duration(days:30)))],).getSingle();
    return (r.data['total'] as int?)??0;
  }

  Future<void> prosesStockOpname({required int barangId, required int stokFisik, String? keterangan}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b)=>b.id.equals(barangId))).getSingle();
      final selisih = stokFisik-barang.stok;
      if(selisih==0) return;
      await (update(db.barang)..where((b)=>b.id.equals(barangId))).write(BarangCompanion(stok: Value(stokFisik), updatedAt: Value(DateTime.now())));
      await into(db.stockOpname).insert(StockOpnameCompanion.insert(barangId: barangId, stokSistem: barang.stok, stokFisik: stokFisik, selisih: selisih, hppSaatOpname: Value(barang.hppAverage), keterangan: Value(keterangan??'Opname')));
      await into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: selisih>0?'OPNAME_MASUK':'OPNAME_KELUAR', qty: selisih.abs(), qtySisaLog: Value(selisih>0?selisih:0), stokAkhir: stokFisik, hargaBeliSaatItu: Value(barang.hppAverage), refId: Value('OPNAME-${DateTime.now().millisecondsSinceEpoch}')));
    });
  }
}
