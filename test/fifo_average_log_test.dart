import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sony_jaya/core/database/local_database.dart';
import 'package:sony_jaya/core/database/daos/transaksi_dao.dart';

void main() {
  late LocalDatabase db;
  late TransaksiDao dao;

  setUp(() {
    db = LocalDatabase.forTesting(NativeDatabase.memory());
    dao = TransaksiDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('FIFO Log + Average HPP harus benar', () async {
    final id = await db.into(db.barang).insert(BarangCompanion.insert(
      nama: 'Semen', satuan: 'sak', stok: 0, hppAverage: 0
    ));

    await dao.prosesPembelian(barangId: id, qtyPcs: 10, hargaBeli: 10000);
    await dao.prosesPembelian(barangId: id, qtyPcs: 10, hargaBeli: 12000);

    var barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
    expect(barang.stok, 20);
    expect(barang.hppAverage, 11000); // (10*10k + 10*12k)/20

    await dao.prosesPenjualan(barangId: id, qtyPcs: 12, hargaJual: 15000);

    barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
    expect(barang.stok, 8);

    final logs = await (db.select(db.kartuStok)
     ..where((k) => k.barangId.equals(id))
     ..where((k) => k.tipe.equals('MASUK'))
     ..orderBy([(k) => OrderingTerm.asc(k.tanggal)])
    ).get();

    expect(logs[0].qtySisaLog, 0); // 10 habis
    expect(logs[1].qtySisaLog, 8); // 10-2
  });

  test('P001 anti minus harus lempar Exception', () async {
    final id = await db.into(db.barang).insert(BarangCompanion.insert(
      nama: 'Besi', satuan: 'batang', stok: 5, hppAverage: 10000
    ));
    expect(() => dao.prosesPenjualan(barangId: id, qtyPcs: 100, hargaJual: 15000),
      throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('P001'))));
  });
}