import 'package:drift/drift.dart';
import '../local_database.dart';
part 'laporan_dao.g.dart';

@DriftAccessor(tables: [Barang, Pembelian, Penjualan, KartuStok])
class LaporanDao extends DatabaseAccessor<LocalDatabase> with _$LaporanDaoMixin {
  LaporanDao(super.db);

  Future<List<KartuStokData>> getKartuStokFiltered(int barangId, {DateTime? start, DateTime? end}) {
    final q = select(kartuStok)..where((k) => k.barangId.equals(barangId))..orderBy([(k) => OrderingTerm.desc(k.tanggal)]);
    if (start!= null) q.where((k) => k.tanggal.isBiggerOrEqualValue(start));
    if (end!= null) q.where((k) => k.tanggal.isSmallerOrEqualValue(end.add(const Duration(days:1))));
    return q.get();
  }

  Future<double> getLabaHariIni() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final query = await customSelect('SELECT SUM(laba) as total FROM penjualan WHERE tanggal >=?', variables: [Variable.withDateTime(start)]).getSingle();
    return (query.data['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getLabaPeriode(DateTime start, DateTime end) async {
    final q = await customSelect('SELECT SUM(laba) as total FROM penjualan WHERE tanggal >=? AND tanggal <=?', variables: [Variable.withDateTime(start), Variable.withDateTime(end.add(const Duration(days:1)))]).getSingle();
    return (q.data['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<BarangData>> getPerluReorder() {
    return (select(barang)..where((b) => b.stok.isSmallerOrEqual(b.safetyStock))).get();
  }

  Future<List<Map<String, dynamic>>> getPergerakanHpp(int barangId) async {
    final logs = await (select(kartuStok)..where((k) => k.barangId.equals(barangId))..where((k) => k.tipe.isIn(['MASUK','KOREKSI_HPP']))..orderBy([(k) => OrderingTerm.asc(k.tanggal)]))).get();
    return logs.map((e)=>{'tanggal': e.tanggal, 'hpp': e.hargaBeliSaatItu, 'stokAkhir': e.stokAkhir, 'ref': e.refId}).toList();
  }
}