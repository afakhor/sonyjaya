// di dalam loop for (final b in barangs) tambahkan:
final logsHpp = await (db.select(db.kartuStok)..where((k) => k.barangId.equals(b.id))..where((k) => k.tipe.equals('MASUK'))).get();
if (logsHpp.isNotEmpty) {
  final lastHpp = logsHpp.last.hargaBeliSaatItu;
  log('CCTV HPP ${b.nama}: HPP terakhir Rp $lastHpp | Stok ${b.stok}');
}
// deteksi laba harian
final jualHariIni = await db.customSelect('SELECT SUM(laba) as total FROM penjualan WHERE tanggal >=?', variables: [Variable.withDateTime(DateTime.now().subtract(const Duration(days:1)))]).getSingle();
log('CCTV LABA 24J: Rp ${jualHariIni.data['total']??0}');