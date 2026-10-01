import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';

// Stream Provider untuk memantau daftar transaksi secara real-time
final transaksiStreamProvider = StreamProvider.autoDispose<List<TransaksiData>>((ref) {
  final db = ref.watch(localDbProvider);
  // Mengambil data transaksi diurutkan dari yang terbaru
  return (db.select(db.transaksi)..orderBy([(t) => OrderingTerm.desc(t.tanggal)])).watch();
});
