import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../../core/cache/isar_service.dart';

// Model fallback jika collection belum ada - pakai dynamic
// Kalau IsarService punya suppliers collection, ganti dengan query asli
final supplierStreamProvider = StreamProvider<List<SupplierData>>((ref) async* {
  try {
    final isar = IsarService.db;
    // Coba baca dari Isar - jika collection ada
    final stream = isar.suppliers.where().watch(fireImmediately: true);
    await for (final list in stream) {
      yield list;
    }
  } catch (_) {
    // Fallback: jika collection belum ada atau error, yield empty biar build tidak failed abu-abu
    yield [];
  }
});
