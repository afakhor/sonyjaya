import 'package:drift/drift.dart';
import '../local_database.dart';
part 'barang_dao.g.dart';

@DriftAccessor(tables: [Barang, KartuStok])
class BarangDao extends DatabaseAccessor<LocalDatabase> with _$BarangDaoMixin {
  BarangDao(super.db);
  Stream<List<BarangData>> watchAllBarang() => select(barang).watch();
  
  Future<List<KartuStokData>> getDeadStockLog(int barangId) {
    final batas = DateTime.now().subtract(const Duration(days: 90));
    return (select(kartuStok)
      ..where((k) => k.barangId.equals(barangId) & k.tipe.equals('MASUK') & k.qtySisaLog.isBiggerThanValue(0) & k.tanggal.isSmallerThanValue(batas))
    ).get();
  }
}