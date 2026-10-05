import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/barang_dao.dart';
import 'daos/transaksi_dao.dart';
import 'daos/laporan_dao.dart';
import 'daos/po_dao.dart';
import 'daos/satuan_dao.dart';
import 'daos/supplier_dao.dart';
import 'daos/pelanggan_dao.dart';
import 'daos/piutang_dao.dart';

part 'local_database.g.dart';

class Barang extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sku => text().nullable()();
  TextColumn get nama => text()();
  TextColumn get merek => text().nullable()();
  TextColumn get satuanTerkecil => text().withDefault(const Constant('Pcs'))();
  TextColumn get satuanBesar => text().withDefault(const Constant('Set'))();
  IntColumn get konversi => integer().withDefault(const Constant(1))();
  IntColumn get stok => integer().withDefault(const Constant(0))();
  IntColumn get safetyStock => integer().withDefault(const Constant(2))();
  RealColumn get hppAverage => real().withDefault(const Constant(0))();
  RealColumn get hargaEcer => real().withDefault(const Constant(0))();
  RealColumn get hargaAgen => real().withDefault(const Constant(0))();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Supplier extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().unique()();
  TextColumn get kontak => text().nullable()();
  TextColumn get alamat => text().nullable()();
  TextColumn get keterangan => text().nullable()();
  IntColumn get topDefault => integer().withDefault(const Constant(14))();
}

class PelangganMaster extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().unique()();
  TextColumn get kontak => text().nullable()();
  TextColumn get alamat => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('PEMBELI'))();
  RealColumn get totalBelanja => real().withDefault(const Constant(0))();
  IntColumn get frekuensi => integer().withDefault(const Constant(0))();
  IntColumn get variasiBarang => integer().withDefault(const Constant(0))();
  IntColumn get totalQty => integer().withDefault(const Constant(0))();
  RealColumn get skorRating => real().withDefault(const Constant(0))();
  RealColumn get totalPiutangAktif => real().withDefault(const Constant(0))();
  DateTimeColumn get lastBeli => dateTime().nullable()();
}

class PurchaseOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get noPo => text().unique()();
  TextColumn get tipePo => text().withDefault(const Constant('VENDOR'))();
  TextColumn get namaRelasi => text()();
  TextColumn get kontakRelasi => text().nullable()();
  TextColumn get alamatRelasi => text().nullable()();
  DateTimeColumn get tanggalPo => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get estimasiKirim => dateTime().nullable()();
  RealColumn get totalKeseluruhan => real().withDefault(const Constant(0))();
  TextColumn get statusBayar => text().withDefault(const Constant('LUNAS'))();
  TextColumn get statusPo => text().withDefault(const Constant('SELESAI'))();
  TextColumn get keterangan => text().nullable()();
}

class PurchaseOrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get poId => integer()();
  IntColumn get barangId => integer()();
  IntColumn get qty => integer()();
  TextColumn get satuan => text().withDefault(const Constant('Pcs'))();
  RealColumn get hargaSatuan => real()();
  RealColumn get subtotal => real()();
  RealColumn get hppSaatTransaksi => real().withDefault(const Constant(0))();
}

class PelangganPiutang extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get penjualanId => integer().nullable()();
  TextColumn get noNota => text()();
  TextColumn get pelangganNama => text()();
  RealColumn get totalTagihan => real()();
  RealColumn get totalDibayar => real().withDefault(const Constant(0))();
  RealColumn get sisaPiutang => real()();
  IntColumn get topDays => integer().withDefault(const Constant(14))();
  DateTimeColumn get tanggalNota => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get jatuhTempo => dateTime()();
  TextColumn get statusBayar => text().withDefault(const Constant('BELUM_LUNAS'))();
  DateTimeColumn get tanggalLunas => dateTime().nullable()();
  TextColumn get keterangan => text().nullable()();
}

class PembayaranPiutang extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get piutangId => integer().customConstraint('NOT NULL REFERENCES pelanggan_piutang(id) ON DELETE CASCADE')();
  RealColumn get jumlahBayar => real()();
  DateTimeColumn get tanggalBayar => dateTime().withDefault(currentDateAndTime)();
  TextColumn get metode => text().withDefault(const Constant('TRANSFER'))();
  TextColumn get catatan => text().nullable()();
}

class Pembelian extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer()();
  IntColumn get qtyPcs => integer()();
  RealColumn get hargaBeliPerPcs => real()();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class Penjualan extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer()();
  IntColumn get qtyPcs => integer()();
  RealColumn get hargaJualPerPcs => real()();
  RealColumn get hppSnapshot => real().withDefault(const Constant(0))();
  RealColumn get laba => real().withDefault(const Constant(0))();
  TextColumn get tipe => text().withDefault(const Constant('eceran'))();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class KartuStok extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer()();
  TextColumn get tipe => text()();
  IntColumn get qty => integer()();
  IntColumn get qtySisaLog => integer().withDefault(const Constant(0))();
  IntColumn get stokAkhir => integer()();
  RealColumn get hargaBeliSaatItu => real().nullable()();
  TextColumn get refId => text().nullable()();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class StockOpname extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer()();
  IntColumn get stokSistem => integer()();
  IntColumn get stokFisik => integer()();
  IntColumn get selisih => integer()();
  RealColumn get hppSaatOpname => real().withDefault(const Constant(0))();
  TextColumn get keterangan => text().nullable()();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class Satuan extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namaSatuan => text().unique()();
}

@DriftDatabase(tables: [Barang,Supplier,PelangganMaster,PurchaseOrders,PurchaseOrderItems,PelangganPiutang,PembayaranPiutang,Pembelian,Penjualan,KartuStok,StockOpname,Satuan], daos: [BarangDao,TransaksiDao,LaporanDao,PoDao,SatuanDao,SupplierDao,PelangganMasterDao,PiutangDao])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(driftDatabase(name: 'sony_jaya_v7'));
  @override int get schemaVersion => 7;
  @override MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if(from<7){
        await m.createTable(pelangganMaster);
        await m.createTable(pelangganPiutang);
        await m.createTable(pembayaranPiutang);
      }
    },
  );
}