import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/barang_dao.dart';
import 'daos/transaksi_dao.dart';

part 'local_database.g.dart';

// === SEMUA TABEL JADI SATU DISINI ===

class Barang extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sku => text().unique()();
  TextColumn get nama => text()();
  TextColumn get merek => text().nullable()();
  TextColumn get satuanTerkecil => text().withDefault(const Constant('Pcs'))();
  TextColumn get satuanBesar => text().withDefault(const Constant('Dus'))();
  IntColumn get konversi => integer().withDefault(const Constant(24))();
  RealColumn get hppAverage => real().withDefault(const Constant(0))();
  RealColumn get hargaEcer => real().withDefault(const Constant(0))();
  RealColumn get hargaAgen => real().withDefault(const Constant(0))();
  IntColumn get stok => integer().withDefault(const Constant(0))();
  IntColumn get safetyStock => integer().withDefault(const Constant(5))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Pembelian extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer().customConstraint('REFERENCES barang(id)')();
  IntColumn get qtyPcs => integer()();
  RealColumn get hargaBeliPerPcs => real()();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class Penjualan extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer().customConstraint('REFERENCES barang(id)')();
  IntColumn get qtyPcs => integer()();
  RealColumn get hargaJualPerPcs => real()();
  RealColumn get hppSnapshot => real()();
  RealColumn get laba => real()();
  TextColumn get tipe => text().withDefault(const Constant('ecer'))();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

class KartuStok extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get barangId => integer().customConstraint('REFERENCES barang(id)')();
  TextColumn get tipe => text()(); // MASUK | KELUAR
  IntColumn get qty => integer()();
  IntColumn get qtySisaLog => integer().withDefault(const Constant(0))(); // KUNCI FIFO TANPA BATCH
  IntColumn get stokAkhir => integer()();
  RealColumn get hargaBeliSaatItu => real().withDefault(const Constant(0))();
  TextColumn get refId => text().nullable()();
  DateTimeColumn get tanggal => dateTime().withDefault(currentDateAndTime)();
}

// === DATABASE UTAMA - FINAL MATANG ===
@DriftDatabase(tables: [Barang, Pembelian, Penjualan, KartuStok], daos: [BarangDao, TransaksiDao])
class LocalDatabase extends _$LocalDatabase {
  // SINGLETON - Anti bocor memory & Anti Race Condition P001
  LocalDatabase._internal() : super(driftDatabase(name: 'sony_jaya_hpp_v3'));
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 3) {
        await m.createAll();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}