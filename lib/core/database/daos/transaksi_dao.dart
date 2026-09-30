import 'package:drift/drift.dart';
import '../local_database.dart';
part 'transaksi_dao.g.dart';

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok])
class TransaksiDao extends DatabaseAccessor<LocalDatabase> with _$TransaksiDaoMixin {
  TransaksiDao(super.db);

  Future<void> prosesPembelian({required int barangId, required int qtyPcs, required double hargaBeli, String? supplier}) async {                                     await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      final hppBaru = (barang.stok + qtyPcs) == 0 ? hargaBeli : ((barang.stok * barang.hppAverage) + (qtyPcs * hargaBeli)) / (barang.stok + qtyPcs);
      final stokBaru = barang.stok + qtyPcs;

      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(
        BarangCompanion(stok: Value(stokBaru), hppAverage: Value(hppBaru), updatedAt: Value(DateTime.now()))
      );

      final idBeli = await into(db.pembelian).insert(
        PembelianCompanion.insert(barangId: barangId, qtyPcs: qtyPcs, hargaBeliPerPcs: hargaBeli, supplier: Value(supplier))
      );

      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId, tipe: 'MASUK', qty: qtyPcs, qtySisaLog: Value(qtyPcs),
        stokAkhir: stokBaru, hargaBeliSaatItu: Value(hargaBeli), refId: Value('BELI-$idBeli')
      ));
    });
  }

  Future<void> prosesPenjualan({required int barangId, required int qtyPcs, required double hargaJual, String tipe = 'ecer'}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      if (barang.stok < qtyPcs) throw Exception('P001 STOK ${barang.nama} MINUS DITOLAK. Sisa ${barang.stok}');

      int sisaJual = qtyPcs;
      final logs = await (select(db.kartuStok)
        ..where((k) => k.barangId.equals(barangId) & k.tipe.equals('MASUK') & k.qtySisaLog.isBiggerThanValue(0))
        ..orderBy([(k) => OrderingTerm.asc(k.tanggal)])
      ).get();

      for (final log in logs) {
        if (sisaJual <= 0) break;
        final ambil = sisaJual > log.qtySisaLog ? log.qtySisaLog : sisaJual;
        await (update(db.kartuStok)..where((k) => k.id.equals(log.id))).write(
          KartuStokCompanion(qtySisaLog: Value(log.qtySisaLog - ambil))
        );
        sisaJual -= ambil;
      }

      final stokBaru = barang.stok - qtyPcs;
      final laba = (hargaJual - barang.hppAverage) * qtyPcs;

      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(
        BarangCompanion(stok: Value(stokBaru), updatedAt: Value(DateTime.now()))
      );

      // FIX DI SINI: laba jangan pakai Value(), langsung laba
      final idJual = await into(db.penjualan).insert(PenjualanCompanion.insert(
        barangId: barangId,
        qtyPcs: qtyPcs,
        hargaJualPerPcs: hargaJual,
        hppSnapshot: barang.hppAverage,
        laba: laba,
        tipe: Value(tipe)
      ));

      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId, tipe: 'KELUAR', qty: -qtyPcs, stokAkhir: stokBaru, refId: Value('JUAL-$idJual')
      ));
    });
  }
}