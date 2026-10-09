// lib/core/database/local_database.dart - V8 FIX BIRU-KUNING-MERAH
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

// ========== TABEL EXISTING ==========
class Barang extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sku => text().unique()(); // SKU induk - auto nyambung ke semua biru
  TextColumn get nama => text()(); // Nama Perkakas
  TextColumn get merek => text().nullable()(); // Bosch, Makita, dll
  TextColumn get supplierNama => text().nullable()(); // auto nyambung dari Master Supplier
  IntColumn get supplierId => integer().nullable()();
  IntColumn get stok => integer().withDefault(const Constant(0))();
  RealColumn get hppAverage => real().withDefault(const Constant(0))();
  RealColumn get hargaEcer => real().withDefault(const Constant(0))();
  RealColumn get hargaAgen => real().withDefault(const Constant(0))();
  TextColumn get satuan => text().withDefault(const Constant('Pcs'))();
  TextColumn get kategori => text().nullable()();
}

// BARU: Variasi unlimited per 1 SKU
class BarangVariasi extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer().customConstraint('NOT NULL REFERENCES barang(id) ON DELETE CASCADE')();
  TextColumn get variasiNama => text()(); // mis: "Mata 10mm", "Merah", "Panjang 2m"
  TextColumn get skuVariasi => text().unique().nullable()(); // SKU variasi opsional
  IntColumn get stok => integer().withDefault(const Constant(0))();
  RealColumn get hargaEcer => real().nullable()();
  RealColumn get hargaAgen => real().nullable()();
  TextColumn get keterangan => text().nullable()();
}

class Supplier extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().unique()();
  TextColumn get kontak => text().nullable()();
  TextColumn get alamat => text().nullable()();
  TextColumn get keterangan => text().nullable()();
  IntColumn get topDefault => integer().withDefault(const Constant(14))();
}

// BARU: Hutang Supplier - sinkron dari Nota Masuk
class HutangSupplier extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get noNota => text().unique()(); // NOTA-55513
  IntColumn get supplierId => integer()();
  TextColumn get supplierNama => text()();
  RealColumn get totalTagihan => real()();
  RealColumn get totalDibayar => real().withDefault(const Constant(0))();
  RealColumn get sisaHutang => real()();
  TextColumn get statusBayar => text().withDefault(const Constant('BELUM_LUNAS'))(); // LUNAS, BELUM_LUNAS, TEMPO
  TextColumn get tipeBayar => text().withDefault(const Constant('TEMPO'))(); // CASH, TEMPO
  DateTimeColumn get tanggalNota => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get jatuhTempo => dateTime()(); // tanggalNota + top
  IntColumn get topDays => integer().withDefault(const Constant(30))();
  DateTimeColumn get tanggalLunas => dateTime().nullable()();
  TextColumn get keterangan => text().nullable()();
}

class PembayaranHutang extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hutangId => integer().customConstraint('NOT NULL REFERENCES hutang_supplier(id) ON DELETE CASCADE')();
  RealColumn get jumlahBayar => real()();
  DateTimeColumn get tanggalBayar => dateTime().withDefault(currentDateAndTime)();
  TextColumn get metode => text().withDefault(const Constant('TRANSFER'))();
  TextColumn get catatan => text().nullable()();
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
  IntColumn get variasiId => integer().nullable()();
  IntColumn get qtyPcs => integer()();
  RealColumn get hargaBeliPerPcs => real()();
  TextColumn get supplier => text().nullable()();
  IntColumn get supplierId => integer().nullable()();
  TextColumn get noNota => text().nullable()();
  TextColumn get tipeBayar => text().withDefault(const Constant('TEMPO'))();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class Penjualan extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer()();
  IntColumn get variasiId => integer().nullable()();
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
  IntColumn get variasiId => integer().nullable()();
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
  IntColumn get variasiId => integer().nullable()();
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

@DriftDatabase(tables: [Barang, BarangVariasi, Supplier, HutangSupplier, PembayaranHutang, PelangganMaster, PurchaseOrders, PurchaseOrderItems, PelangganPiutang, PembayaranPiutang, Pembelian, Penjualan, KartuStok, StockOpname, Satuan], daos: [BarangDao, TransaksiDao, LaporanDao, PoDao, SatuanDao, SupplierDao, PelangganMasterDao, PiutangDao, HutangDao])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(driftDatabase(name: 'sony_jaya_v8'));
  @override int get schemaVersion => 8;
  @override MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if(from < 7){
        await m.createTable(pelangganMaster);
        await m.createTable(pelangganPiutang);
        await m.createTable(pembayaranPiutang);
      }
      if(from < 8){
        await m.createTable(barangVariasi);
        await m.createTable(hutangSupplier);
        await m.createTable(pembayaranHutang);
      }
    },
  );
}

// DAOs
@DriftAccessor(tables: [Barang, BarangVariasi])
class BarangDao extends DatabaseAccessor<LocalDatabase> with _$BarangDaoMixin {
  BarangDao(super.db);
  Stream<List<BarangData>> watchAll() => select(barang).watch();
  Future<BarangData?> getBySku(String sku) => (select(barang)..where((t) => t.sku.equals(sku))).getSingleOrNull();
  Stream<List<BarangVariasiData>> watchVariasi(int barangId) => (select(barangVariasi)..where((t) => t.barangId.equals(barangId))).watch();
  Future<int> insertBarang(BarangCompanion data) => into(barang).insert(data);
  Future<int> insertVariasi(BarangVariasiCompanion data) => into(barangVariasi).insert(data);
}

@DriftAccessor(tables: [Supplier])
class SupplierDao extends DatabaseAccessor<LocalDatabase> with _$SupplierDaoMixin {
  SupplierDao(super.db);
  Stream<List<SupplierData>> watchAll() => select(supplier).watch();
  Future<int> insertSupplier(SupplierCompanion data) => into(supplier).insert(data, mode: InsertMode.insertOrReplace);
  Future<bool> updateSupplier(SupplierData data) => update(supplier).replace(data);
  Future<int> deleteSupplier(int id) => (delete(supplier)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [HutangSupplier, PembayaranHutang])
class HutangDao extends DatabaseAccessor<LocalDatabase> with _$HutangDaoMixin {
  HutangDao(super.db);
  Stream<List<HutangSupplierData>> watchAll() => (select(hutangSupplier)..orderBy([(t) => OrderingTerm.desc(t.tanggalNota)])).watch();
  Future<int> insertHutang(HutangSupplierCompanion data) => into(hutangSupplier).insert(data);
  Future<void> bayarLunas(int hutangId) async {
    await (update(hutangSupplier)..where((t) => t.id.equals(hutangId))).write(HutangSupplierCompanion(statusBayar: Value('LUNAS'), sisaHutang: Value(0), tanggalLunas: Value(DateTime.now())));
  }
}

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok])
class TransaksiDao extends DatabaseAccessor<LocalDatabase> with _$TransaksiDaoMixin { TransaksiDao(super.db); }
@DriftAccessor(tables: [Barang, Penjualan, Pembelian, KartuStok])
class LaporanDao extends DatabaseAccessor<LocalDatabase> with _$LaporanDaoMixin { LaporanDao(super.db); }
@DriftAccessor(tables: [PurchaseOrders, PurchaseOrderItems])
class PoDao extends DatabaseAccessor<LocalDatabase> with _$PoDaoMixin { PoDao(super.db); }
@DriftAccessor(tables: [Satuan])
class SatuanDao extends DatabaseAccessor<LocalDatabase> with _$SatuanDaoMixin { SatuanDao(super.db); }
@DriftAccessor(tables: [PelangganMaster])
class PelangganMasterDao extends DatabaseAccessor<LocalDatabase> with _$PelangganMasterDaoMixin { PelangganMasterDao(super.db); }
@DriftAccessor(tables: [PelangganPiutang, PembayaranPiutang])
class PiutangDao extends DatabaseAccessor<LocalDatabase> with _$PiutangDaoMixin { PiutangDao(super.db); }
