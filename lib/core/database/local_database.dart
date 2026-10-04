import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/barang_dao.dart';
import 'daos/transaksi_dao.dart';
import 'daos/laporan_dao.dart';
import 'daos/po_dao.dart';
import 'daos/satuan_dao.dart';
import 'daos/supplier_dao.dart';
part 'local_database.g.dart';
class Barang extends Table { IntColumn get id => integer().autoIncrement()(); TextColumn get sku => text().nullable().unique()(); TextColumn get nama => text()(); TextColumn get merek => text().nullable()(); TextColumn get satuanTerkecil => text().withDefault(const Constant('Pcs'))(); TextColumn get satuanBesar => text().withDefault(const Constant('Set'))(); IntColumn get konversi => integer().withDefault(const Constant(1))(); RealColumn get hppAverage => real().withDefault(const Constant(0))(); RealColumn get hargaEcer => real().withDefault(const Constant(0))(); RealColumn get hargaAgen => real().withDefault(const Constant(0))(); IntColumn get stok => integer().withDefault(const Constant(0))(); IntColumn get safetyStock => integer().withDefault(const Constant(2))(); DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)(); }
class Pembelian extends Table { IntColumn get id => integer().autoIncrement()(); IntColumn get barangId => integer().customConstraint('NOT NULL REFERENCES barang(id) ON DELETE CASCADE')(); IntColumn get qtyPcs => integer()(); RealColumn get hargaBeliPerPcs => real()(); TextColumn get supplier => text().nullable()(); DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)(); }
class Penjualan extends Table { IntColumn get id => integer().autoIncrement()(); IntColumn get barangId => integer().customConstraint('NOT NULL REFERENCES barang(id) ON DELETE CASCADE')(); IntColumn get qtyPcs => integer()(); RealColumn get hargaJualPerPcs => real()(); RealColumn get hppSnapshot => real()(); RealColumn get laba => real()(); TextColumn get tipe => text().withDefault(const Constant('ecer'))(); DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)(); }
class KartuStok extends Table { IntColumn get id => integer().autoIncrement()(); IntColumn get barangId => integer().customConstraint('NOT NULL REFERENCES barang(id) ON DELETE CASCADE')(); TextColumn get tipe => text()(); IntColumn get qty => integer()(); IntColumn get qtySisaLog => integer().withDefault(const Constant(0))(); IntColumn get stokAkhir => integer()(); RealColumn get hargaBeliSaatItu => real().withDefault(const Constant(0))(); TextColumn get refId => text().nullable()(); DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)(); }
class StockOpname extends Table { IntColumn get id => integer().autoIncrement()(); IntColumn get barangId => integer().customConstraint('NOT NULL REFERENCES barang(id) ON DELETE CASCADE')(); IntColumn get stokSistem => integer()(); IntColumn get stokFisik => integer()(); IntColumn get selisih => integer()(); RealColumn get hppSaatOpname => real()(); TextColumn get keterangan => text().nullable()(); DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)(); }
class Satuan extends Table { IntColumn get id => integer().autoIncrement()(); TextColumn get namaSatuan => text().unique()(); DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)(); }
class PurchaseOrders extends Table { IntColumn get id => integer().autoIncrement()(); TextColumn get noPo => text().unique()(); TextColumn get tipePo => text()(); TextColumn get namaRelasi => text()(); TextColumn get kontakRelasi => text()(); TextColumn get alamatRelasi => text()(); DateTimeColumn get tanggalPo => dateTime().withDefault(currentDateAndTime)(); DateTimeColumn get estimasiKirim => dateTime().nullable()(); TextColumn get statusBayar => text().withDefault(const Constant('LUNAS'))(); RealColumn get totalKeseluruhan => real().withDefault(const Constant(0))(); TextColumn get statusPo => text().withDefault(const Constant('PENDING'))(); }
class PurchaseOrderItems extends Table { IntColumn get id => integer().autoIncrement()(); IntColumn get poId => integer().customConstraint('NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE')(); IntColumn get barangId => integer().customConstraint('NOT NULL REFERENCES barang(id) ON DELETE CASCADE')(); IntColumn get qty => integer()(); TextColumn get satuan => text()(); RealColumn get hargaSatuan => real()(); RealColumn get subtotal => real()(); RealColumn get hppSaatTransaksi => real()(); }
class Supplier extends Table { IntColumn get id => integer().autoIncrement()(); TextColumn get nama => text().unique()(); TextColumn get kontak => text().nullable()(); TextColumn get alamat => text().nullable()(); RealColumn get totalHutang => real().withDefault(const Constant(0))(); DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)(); }
@DriftDatabase(tables: [Barang, Pembelian, Penjualan, KartuStok, StockOpname, Satuan, PurchaseOrders, PurchaseOrderItems, Supplier], daos: [BarangDao, TransaksiDao, LaporanDao, PoDao, SatuanDao, SupplierDao])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._internal() : super(driftDatabase(name: 'sony_jaya_hpp_v5'));
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase.forTesting(super.e);
  @override int get schemaVersion => 6;
  @override MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async { await m.createAll(); await into(satuan).insert(SatuanCompanion.insert(namaSatuan: 'Pcs')); await into(satuan).insert(SatuanCompanion.insert(namaSatuan: 'Set')); await into(satuan).insert(SatuanCompanion.insert(namaSatuan: 'Sak')); await into(satuan).insert(SatuanCompanion.insert(namaSatuan: 'Dus')); await into(satuan).insert(SatuanCompanion.insert(namaSatuan: 'Batang')); },
    onUpgrade: (Migrator m, int from, int to) async { if(from<5){ await m.createAll(); } if(from<6){ await m.createTable(supplier); } },
    beforeOpen: (details) async { await customStatement('PRAGMA foreign_keys = ON'); await customStatement('PRAGMA journal_mode = WAL'); },
  );
}
extension BarangDataCompat on BarangData { String? get satuanKecil => satuanTerkecil; String? get satuan => satuanBesar; String get satuanDasar => satuanTerkecil; }
extension PurchaseOrderCompat on PurchaseOrder { DateTime get tanggalBuat => tanggalPo; }
typedef PurchaseOrderData = PurchaseOrder;
typedef PurchaseOrdersData = PurchaseOrder;
