import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

final transaksiStreamProvider = StreamProvider.autoDispose<List<PenjualanData>>((ref) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.penjualan)
        ..orderBy([(t) => drift.OrderingTerm(expression: t.tanggal, mode: drift.OrderingMode.desc)]))
      .watch();
});
