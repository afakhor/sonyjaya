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

  group('Unit Test FIFO & Moving Average HPP Audit Trail', () {
    test('FIFO Log + Average HPP harus benar', () async {
      // 1. Inisialisasi Data Barang
      final id = await db.into(db.barang).insert(BarangCompanion.insert(
        nama: 'Mata Bor Beton 6mm',
        merek: const Value('Bosch'),
        satuanTerkecil: const Value('Pcs'),
        satuanBesar: const Value('Set'),
        stok: const Value(0),
        hppAverage: const Value(0),
      ));

      // 2. Pembelian Batch 1: 10 Pcs @ Rp 15.000 (Total Rp 150.000)
      await dao.prosesPembelian(barangId: id, qtyPcs: 10, hargaBeli: 15000);

      // 3. Pembelian Batch 2: 10 Pcs @ Rp 17.000 (Total Rp 170.000)
      await dao.prosesPembelian(barangId: id, qtyPcs: 10, hargaBeli: 17000);

      // Verifikasi Moving Average HPP = (150.000 + 170.000) / 20 = 16.000
      var barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
      expect(barang.stok, 20);
      expect(barang.hppAverage, 16000);

      // 4. Penjualan 12 Pcs @ Rp 25.000
      // FIFO Audit: 10 Pcs dari Batch 1 (HPP 15.000) + 2 Pcs dari Batch 2 (HPP 17.000)
      await dao.prosesPenjualan(barangId: id, qtyPcs: 12, hargaJual: 25000);

      // 5. Verifikasi Sisa Stok (20 - 12 = 8 Pcs)
      barang = await (db.select(db.barang)..where((b) => b.id.equals(id))).getSingle();
      expect(barang.stok, 8);

      // 6. Verifikasi Pencatatan Penjualan
      final listPenjualan = await (db.select(db.penjualan)..where((p) => p.barangId.equals(id))).get();
      expect(listPenjualan.isNotEmpty, isTrue);
      final lastPenjualan = listPenjualan.last;
      expect(lastPenjualan.qtyPcs, 12);

      // 7. Verifikasi Riwayat Kartu Stok (Harus tercatat 2 Pembelian + 1 Penjualan)
      final kartuStok = await (db.select(db.kartuStok)..where((k) => k.barangId.equals(id))).get();
      expect(kartuStok.length, 3);
    });

    test('P001 anti minus harus lempar Exception', () async {
      final id = await db.into(db.barang).insert(BarangCompanion.insert(
        nama: 'Palu Kambing 18"',
        merek: const Value('Tekiro'),
        satuanTerkecil: const Value('Pcs'),
        stok: const Value(5),
        hppAverage: const Value(45000),
      ));

      // Upaya transaksi melebihi stok yang tersedia (100 > 5)
      expect(
        () => dao.prosesPenjualan(barangId: id, qtyPcs: 100, hargaJual: 15000),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'msg',
            contains('P001'),
          ),
        ),
      );
    });
  });
}
