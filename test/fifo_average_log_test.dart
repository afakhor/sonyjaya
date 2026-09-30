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
      nama: 'Mata Bor Beton 6mm',
      merek: Value('Bosch'),
      satuanTerkecil: Value('Pcs'), // Pcs bukan sak
      satuanBesar: Value('Set'),
      stok: Value(0),
      hppAverage: Value(0),
    ));

    await dao.prosesPembelian(barangId: id, qtyPcs: 10, hargaBeli: 15000);
    await dao.prosesPembelian(barangId: id, qtyPcs: 10, hargaBeli: 17000);
    // HPP = 16000

    var barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
    expect(barang.stok, 20);
    expect(barang.hppAverage, 16000);

    await dao.prosesPenjualan(barangId: id, qtyPcs: 12, hargaJual: 25000);
    // ...
  });

  test('P001 anti minus harus lempar Exception', () async {
    final id = await db.into(db.barang).insert(BarangCompanion.insert(
      nama: 'Palu Kambing 18"',
      merek: Value('Tekiro'),
      satuanTerkecil: Value('Pcs'),
      stok: Value(5),
      hppAverage: Value(45000),
    ));

    expect(() => dao.prosesPenjualan(barangId: id, qtyPcs: 100, hargaJual: 15000),
      throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('P001'))));
  });
}