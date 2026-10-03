import 'package:drift/drift.dart';
import '../local_database.dart';
part 'transaksi_dao.g.dart';

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok, StockOpname])
class TransaksiDao extends DatabaseAccessor<LocalDatabase> with _$TransaksiDaoMixin {
  TransaksiDao(super.db);

  // BELI = HPP AUTO MOVING AVERAGE + TANGGAL + NOTA + LOG
  Future<void> prosesPembelian({
    required int barangId, 
    required int qtyInput, 
    required double hargaBeliPerSatuanInput, 
    bool isSatuanBesar = false,
    String? supplier,
    DateTime? tanggal, // FIX TANGGAL
    String? refId, // NOTA
  }) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      final tgl = tanggal ?? DateTime.now();

      final int multiplier = isSatuanBesar ? barang.konversi : 1;
      final int qtyPcsTotal = qtyInput * multiplier;
      final double hargaBeliPerPcs = isSatuanBesar ? (hargaBeliPerSatuanInput / multiplier) : hargaBeliPerSatuanInput;

      // RUMUS MOVING AVERAGE AUTO
      final double hppBaru;
      if (barang.stok <= 0) {
        hppBaru = hargaBeliPerPcs;
      } else {
        hppBaru = ((barang.stok * barang.hppAverage) + (qtyPcsTotal * hargaBeliPerPcs)) / (barang.stok + qtyPcsTotal);
      }

      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(
        BarangCompanion(stok: Value(barang.stok + qtyPcsTotal), hppAverage: Value(hppBaru), updatedAt: Value(tgl)),
      );

      final idBeli = await into(db.pembelian).insert(PembelianCompanion.insert(
        barangId: barangId, 
        qtyPcs: qtyPcsTotal, 
        hargaBeliPerPcs: hargaBeliPerPcs, 
        supplier: Value(supplier),
        tanggal: Value(tgl),
      ));

      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId, 
        tipe: 'MASUK', 
        qty: qtyPcsTotal, 
        qtySisaLog: Value(qtyPcsTotal),
        stokAkhir: barang.stok + qtyPcsTotal, 
        hargaBeliSaatItu: Value(hargaBeliPerPcs), 
        refId: Value(refId ?? 'BELI-$idBeli'),
        tanggal: Value(tgl),
      ));
    });
  }

  Future<void> koreksiHppTanpaBeli({required int barangId, required double hppBaru, required String keterangan}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId, tipe: 'KOREKSI_HPP', qty: 0, stokAkhir: barang.stok, hargaBeliSaatItu: Value(hppBaru), refId: Value(keterangan), tanggal: Value(DateTime.now()),
      ));
      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(BarangCompanion(hppAverage: Value(hppBaru), updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> prosesPenjualan({required int barangId, required int qtyInput, required double hargaJualPerSatuanInput, bool isSatuanBesar = false, String tipe = 'ecer'}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      final int multiplier = isSatuanBesar ? barang.konversi : 1;
      final int qtyPcsTotal = qtyInput * multiplier;
      final double hargaJualPerPcs = isSatuanBesar ? (hargaJualPerSatuanInput / multiplier) : hargaJualPerSatuanInput;
      if (barang.stok < qtyPcsTotal) throw Exception('STOK MINUS: ${barang.nama} sisa ${barang.stok}');
      if (hargaJualPerPcs < barang.hppAverage) throw Exception('MARGIN GUARD: Jual di bawah HPP!');
      int sisaJual = qtyPcsTotal;
      final logs = await (select(db.kartuStok)..where((k) => k.barangId.equals(barangId))..where((k) => k.tipe.equals('MASUK'))..where((k) => k.qtySisaLog.isBiggerThanValue(0))..orderBy([(k) => OrderingTerm.asc(k.tanggal)])).get();
      for (final log in logs) {
        if (sisaJual <= 0) break;
        final ambil = sisaJual > log.qtySisaLog ? log.qtySisaLog : sisaJual;
        await (update(db.kartuStok)..where((k) => k.id.equals(log.id))).write(KartuStokCompanion(qtySisaLog: Value(log.qtySisaLog - ambil)));
        sisaJual -= ambil;
      }
      final stokBaru = barang.stok - qtyPcsTotal;
      final laba = (hargaJualPerSatuanInput * qtyInput) - (barang.hppAverage * qtyPcsTotal);
      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(BarangCompanion(stok: Value(stokBaru), updatedAt: Value(DateTime.now())));
      final idJual = await into(db.penjualan).insert(PenjualanCompanion.insert(barangId: barangId, qtyPcs: qtyPcsTotal, hargaJualPerPcs: hargaJualPerPcs, hppSnapshot: barang.hppAverage, laba: laba, tipe: Value(tipe)));
      await into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: 'KELUAR', qty: -qtyPcsTotal, stokAkhir: stokBaru, refId: Value('JUAL-$idJual')));
    });
  }

  Future<void> prosesStockOpname({required int barangId, required int stokFisik, String? keterangan}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      final selisih = stokFisik - barang.stok;
      if (selisih == 0) return;
      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(BarangCompanion(stok: Value(stokFisik), updatedAt: Value(DateTime.now())));
      await into(db.stockOpname).insert(StockOpnameCompanion.insert(barangId: barangId, stokSistem: barang.stok, stokFisik: stokFisik, selisih: selisih, hppSaatOpname: barang.hppAverage, keterangan: Value(keterangan ?? 'Opname')));
      await into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: selisih > 0 ? 'OPNAME_MASUK' : 'OPNAME_KELUAR', qty: selisih.abs(), qtySisaLog: Value(selisih > 0 ? selisih : 0), stokAkhir: stokFisik, hargaBeliSaatItu: Value(barang.hppAverage), refId: Value('OPNAME-${DateTime.now().millisecondsSinceEpoch}')));
    });
  }
}