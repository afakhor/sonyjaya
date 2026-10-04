import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sony_jaya/core/database/local_database.dart';

void main() {
  late LocalDatabase db;

  setUp(() {
    // pakai memory biar kilat, gak berat kayak Isar
    db = LocalDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Unit Test FIFO & Moving Average HPP Audit Trail', () {
    test('FIFO Log + Average HPP harus benar - Rumus: (Qty Lama*HPP Lama + Qty Baru*Harga Baru)/(Qty Lama+Qty Baru)', () async {
      final id = await db.into(db.barang).insert(BarangCompanion.insert(
        nama: 'Mata Bor Beton 6mm',
        merek: const Value('Bosch'),
        satuanTerkecil: const Value('Pcs'),
        satuanBesar: const Value('Set'),
        stok: const Value(0),
        hppAverage: const Value(0),
      ));

      // Batch 1: 10 Pcs @ 15.000
      await db.transaksiDao.prosesPembelian(
        barangId: id,
        qtyInput: 10,
        hargaBeliPerSatuanInput: 15000,
        isSatuanBesar: false,
        tanggal: DateTime.now(),
        refId: 'TEST-001',
      );

      // Batch 2: 10 Pcs @ 17.000
      await db.transaksiDao.prosesPembelian(
        barangId: id,
        qtyInput: 10,
        hargaBeliPerSatuanInput: 17000,
        isSatuanBesar: false,
        tanggal: DateTime.now(),
        refId: 'TEST-002',
      );

      var barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
      expect(barang.stok, 20);
      // (0*0 + 10*15000 + 10*17000)/20 = 16000
      expect(barang.hppAverage, 16000);

      // Jual 12 Pcs
      await db.transaksiDao.prosesPenjualan(
        barangId: id,
        qtyInput: 12,
        hargaJual: 25000,
        isSatuanBesar: false,
        tanggal: DateTime.now(),
      );

      barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
      expect(barang.stok, 8);

      final kartuStok = await (db.select(db.kartuStok)..where((k) => k.barangId.equals(id))).get();
      expect(kartuStok.length, 3); // 2 MASUK + 1 KELUAR
      expect(kartuStok.where((e) => e.tipe == 'KELUAR').length, 1);
      expect(kartuStok.where((e) => e.tipe == 'MASUK').length, 2);
    });

    test('P001 anti minus harus lempar Exception', () async {
      final id = await db.into(db.barang).insert(BarangCompanion.insert(
        nama: 'Palu Kambing 18"',
        merek: const Value('Tekiro'),
        satuanTerkecil: const Value('Pcs'),
        stok: const Value(5),
        hppAverage: const Value(45000),
      ));

      expect(
        () => db.transaksiDao.prosesPenjualan(barangId: id, qtyInput: 100, hargaJual: 15000),
        throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('P001'))),
      );
    });
  });
}