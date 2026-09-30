import 'package:drift/drift.dart';
import '../local_database.dart';
part 'laporan_dao.g.dart';

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok])
class LaporanDao extends DatabaseAccessor<LocalDatabase> with _$LaporanDaoMixin {
  LaporanDao(super.db);

  // Kartu Stok lengkap untuk 1 barang
  Future<List<KartuStokData>> getKartuStok(int barangId) {
    return (select(kartuStok)..where((k) => k.barangId.equals(barangId))..orderBy([(k) => OrderingTerm.desc(k.tanggal)])).get();
  }

  // Laba hari ini
  Future<double> getLabaHariIni() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final query = await customSelect(
      'SELECT SUM(laba) as total FROM penjualan WHERE tanggal >= ?',
      variables: [Variable.withDateTime(start)]
    ).getSingle();
    return query.data['total'] as double? ?? 0.0;
  }

  // Barang perlu reorder (stok <= safety)
  Future<List<BarangData>> getPerluReorder() {
    return (select(barang)..where((b) => b.stok.isSmallerOrEqual(b.safetyStock))).get();
  }
}