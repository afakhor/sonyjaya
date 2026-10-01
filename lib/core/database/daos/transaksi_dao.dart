import 'package:drift/drift.dart';
import '../local_database.dart';
part 'transaksi_dao.g.dart';

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok, StockOpname])
class TransaksiDao extends DatabaseAccessor<LocalDatabase> with _$TransaksiDaoMixin {
  TransaksiDao(super.db);

  /// Proses Pembelian (Mendukung Satuan Kecil atau Konversi Satuan Besar ke Pcs)
  Future<void> prosesPembelian({
    required int barangId, 
    required int qtyInput, 
    required double hargaBeliPerSatuanInput, 
    bool isSatuanBesar = false, // True jika beli dalam Dus/Roll
    String? supplier
  }) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      
      // Konversi ke basis Pcs jika input menggunakan satuan besar
      final int multiplier = isSatuanBesar ? barang.konversi : 1;
      final int qtyPcsTotal = qtyInput * multiplier;
      final double hargaBeliPerPcs = isSatuanBesar ? (hargaBeliPerSatuanInput / multiplier) : hargaBeliPerSatuanInput;

      // Hitung HPP Rata-rata Tertimbang (Weighted Average HPP)
      final stokLama = barang.stok;
      final stokBaru = stokLama + qtyPcsTotal;
      
      final hppBaru = stokBaru == 0 
          ? hargaBeliPerPcs 
          : ((stokLama * barang.hppAverage) + (qtyPcsTotal * hargaBeliPerPcs)) / stokBaru;

      // Update Data Barang
      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(
        BarangCompanion(
          stok: Value(stokBaru), 
          hppAverage: Value(hppBaru), 
          updatedAt: Value(DateTime.now()),
        )
      );

      // Catat ke Tabel Pembelian
      final idBeli = await into(db.pembelian).insert(
        PembelianCompanion.insert(
          barangId: barangId, 
          qtyPcs: qtyPcsTotal, 
          hargaBeliPerPcs: hargaBeliPerPcs, 
          supplier: Value(supplier),
        )
      );

      // Catat ke Kartu Stok (FIFO Masuk dengan sisa log)
      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId, 
        tipe: 'MASUK', 
        qty: qtyPcsTotal, 
        qtySisaLog: Value(qtyPcsTotal),
        stokAkhir: stokBaru, 
        hargaBeliSaatItu: Value(hargaBeliPerPcs), 
        refId: Value('BELI-$idBeli'),
      ));
    });
  }

  /// Proses Penjualan (Mendukung Satuan Kecil / Besar + FIFO & Margin Guardian)
  Future<void> prosesPenjualan({
    required int barangId, 
    required int qtyInput, 
    required double hargaJualPerSatuanInput, 
    bool isSatuanBesar = false, // True jika jual dalam Dus/Roll
    String tipe = 'ecer'
  }) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      
      // Konversi ke basis Pcs
      final int multiplier = isSatuanBesar ? barang.konversi : 1;
      final int qtyPcsTotal = qtyInput * multiplier;
      final double hargaJualPerPcs = isSatuanBesar ? (hargaJualPerSatuanInput / multiplier) : hargaJualPerSatuanInput;

      // Validasi Stok
      if (barang.stok < qtyPcsTotal) {
        throw Exception('P001 STOK ${barang.nama} MINUS DITOLAK. Sisa ${barang.stok}, Diminta ${qtyPcsTotal}');
      }

      // Validasi Margin Guardian (Cegah Jual di Bawah HPP)
      if (hargaJualPerPcs < barang.hppAverage) {
        throw Exception('MARGIN GUARD: Harga jual (Rp $hargaJualPerPcs) di bawah HPP (Rp ${barang.hppAverage}) ditolak!');
      }

      // Eksekusi Pemotongan Stok FIFO dari Log Masuk
      int sisaJual = qtyPcsTotal;
      final logs = await (select(db.kartuStok)
       ..where((k) => k.barangId.equals(barangId))
       ..where((k) => k.tipe.equals('MASUK'))
       ..where((k) => k.qtySisaLog.isBiggerThanValue(0))
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

      final stokBaru = barang.stok - qtyPcsTotal;
      final totalOmset = hargaJualPerSatuanInput * qtyInput;
      final totalHpp = barang.hppAverage * qtyPcsTotal;
      final laba = totalOmset - totalHpp;

      // Update Stok Barang Utama
      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(
        BarangCompanion(stok: Value(stokBaru), updatedAt: Value(DateTime.now()))
      );

      // Catat ke Tabel Penjualan
      final idJual = await into(db.penjualan).insert(PenjualanCompanion.insert(
        barangId: barangId, 
        qtyPcs: qtyPcsTotal, 
        hargaJualPerPcs: hargaJualPerPcs,
        hppSnapshot: barang.hppAverage, 
        laba: laba, 
        tipe: Value(tipe),
      ));

      // Catat ke Kartu Stok Keluar
      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId, 
        tipe: 'KELUAR', 
        qty: -qtyPcsTotal, 
        stokAkhir: stokBaru, 
        refId: Value('JUAL-$idJual'),
      ));
    });
  }

  /// Proses Stock Opname (Koreksi Fisik Gudang)
  Future<void> prosesStockOpname({required int barangId, required int stokFisik, String? keterangan}) async {
    await transaction(() async {
      final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();
      final selisih = stokFisik - barang.stok;
      if (selisih == 0) return;

      await (update(db.barang)..where((b) => b.id.equals(barangId))).write(
        BarangCompanion(stok: Value(stokFisik), updatedAt: Value(DateTime.now()))
      );

      await into(db.stockOpname).insert(StockOpnameCompanion.insert(
        barangId: barangId,
        stokSistem: barang.stok,
        stokFisik: stokFisik,
        selisih: selisih,
        hppSaatOpname: barang.hppAverage,
        keterangan: Value(keterangan ?? 'Opname Mandiri Gudang'),
      ));

      await into(db.kartuStok).insert(KartuStokCompanion.insert(
        barangId: barangId,
        tipe: selisih > 0 ? 'OPNAME_MASUK' : 'OPNAME_KELUAR',
        qty: selisih.abs(),
        qtySisaLog: Value(selisih > 0 ? selisih : 0),
        stokAkhir: stokFisik,
        hargaBeliSaatItu: Value(barang.hppAverage),
        refId: Value('OPNAME-${DateTime.now().millisecondsSinceEpoch}'),
      ));
    });
  }
}
