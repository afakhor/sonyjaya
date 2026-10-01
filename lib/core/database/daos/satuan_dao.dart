import 'package:drift/drift.dart';
import '../local_database.dart';
part 'satuan_dao.g.dart';

@DriftAccessor(tables: [Satuan])
class SatuanDao extends DatabaseAccessor<LocalDatabase> with _$SatuanDaoMixin {
  SatuanDao(super.db);

  Stream<List<SatuanData>> watchAllSatuan() => (select(satuan)..orderBy([(s) => OrderingTerm.asc(s.namaSatuan)])).watch();

  Future<void> tambahSatuan(String namaBaru) async {
    final cleanName = namaBaru.trim().toUpperCase();
    if (cleanName.isEmpty) return;
    
    final existing = await (select(satuan)..where((s) => s.namaSatuan.equals(cleanName))).getSingleOrNull();
    if (existing == null) {
      await into(satuan).insert(SatuanCompanion.insert(namaSatuan: cleanName));
    }
  }

  Future<void> hapusSatuan(int id) async {
    await (delete(satuan)..where((s) => s.id.equals(id))).go();
  }
}
