import 'package:drift/drift.dart';
import '../local_database.dart';
part 'barang_dao.g.dart';
@DriftAccessor(tables: [Barang, KartuStok, Pembelian, Penjualan])
class BarangDao extends DatabaseAccessor<LocalDatabase> with _$BarangDaoMixin {
  BarangDao(super.db);
  Stream<List<BarangData>> watchAllBarang() => (select(barang)..orderBy([(b)=>OrderingTerm.asc(b.nama)])).watch();
  Stream<List<BarangData>> watchCari(String keyword) => (select(barang)..where((b)=> b.nama.like('%$keyword%') | b.sku.like('%$keyword%') | b.merek.like('%$keyword%'))).watch();
  Future<List<BarangData>> cariBarang(String keyword) => (select(barang)..where((b)=> b.nama.like('%$keyword%') | b.sku.like('%$keyword%') | b.merek.like('%$keyword%'))..limit(10)).get();
  Future<BarangData> getById(int id) => (select(barang)..where((b)=>b.id.equals(id))).getSingle();
  Future<int> insertBarang(BarangCompanion data) => into(barang).insert(data);
  Future<void> updateBarang(BarangData data) => update(barang).replace(data);
  Future<void> deleteBarang(int id) => (delete(barang)..where((b)=>b.id.equals(id))).go();
  Future<List<KartuStokData>> getDeadStockLog(int barangId) { final batas = DateTime.now().subtract(const Duration(days:90)); return (select(kartuStok)..where((k)=>k.barangId.equals(barangId) & k.tipe.equals('MASUK') & k.qtySisaLog.isBiggerThanValue(0) & k.tanggal.isSmallerThanValue(batas))..orderBy([(k)=>OrderingTerm.asc(k.tanggal)])).get(); }
  Future<List<KartuStokData>> getFifoTertua(int barangId) => (select(kartuStok)..where((k)=>k.barangId.equals(barangId) & k.tipe.equals('MASUK') & k.qtySisaLog.isBiggerThanValue(0))..orderBy([(k)=>OrderingTerm.asc(k.tanggal)])).get();
  Future<void> updateSafetyStock(int barangId, int newSafety) async { await (update(barang)..where((b)=>b.id.equals(barangId))).write(BarangCompanion(safetyStock: Value(newSafety), updatedAt: Value(DateTime.now()))); }
}
