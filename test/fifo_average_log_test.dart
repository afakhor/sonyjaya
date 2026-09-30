import 'package:flutter_test/flutter_test.dart';
import 'package:sony_jaya/core/database/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

void main() {
  late LocalDatabase db;
  setUp(() => db = LocalDatabase()..customStatement('PRAGMA foreign_keys = OFF'));

  test('FIFO Log + Average HPP harus benar', () async {
    final idBarang = await db.into(db.barang).insert(BarangCompanion.insert(sku: 'TEST-001', nama: 'Baut 10mm'));

    // Beli 20 @ 1000 tanggal lama
    await db.transaksiDao.prosesPembelian(barangId: idBarang, qtyPcs: 20, hargaBeli: 1000);
    // Beli 30 @ 2000 tanggal baru
    await db.transaksiDao.prosesPembelian(barangId: idBarang, qtyPcs: 30, hargaBeli: 2000);

    final barang = await (db.select(db.barang)..where((b) => b.id.equals(idBarang))).getSingle();
    // HPP Average = (20*1000 + 30*2000)/50 = 1600
    expect(barang.hppAverage, 1600);
    expect(barang.stok, 50);

    // Jual 25 -> harus makan 20 log pertama + 5 log kedua
    await db.transaksiDao.prosesPenjualan(barangId: idBarang, qtyPcs: 25, hargaJual: 2500);

    final logsMasuk = await (db.select(db.kartuStok)..where((k) => k.tipe.equals('MASUK'))..orderBy([(k) => OrderingTerm.asc(k.tanggal)])).get();
    expect(logsMasuk[0].qtySisaLog, 0); // log pertama habis
    expect(logsMasuk[1].qtySisaLog, 25); // log kedua sisa 25

    // Laba harus pakai Average 1600, bukan FIFO
    final jual = await db.select(db.penjualan).getSingle();
    expect(jual.hppSnapshot, 1600);
    expect(jual.laba, (2500-1600)*25);
  });

  test('P001 anti minus harus lempar Exception', () async {
    //... test jual melebihi stok harus throw
  });
}