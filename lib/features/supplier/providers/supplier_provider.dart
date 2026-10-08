import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';

// Provider database lokal Drift - Sony Jaya v7
final localDbProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

// Stream semua supplier - FIX: tidak pakai IsarService.db lagi
final supplierStreamProvider = StreamProvider<List<SupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.select(db.supplier).watch();
});

// Optional: filter pencarian
final filteredSupplierProvider = Provider.family<List<SupplierData>, String>((ref, query) {
  final asyncData = ref.watch(supplierStreamProvider);
  return asyncData.maybeWhen(
    data: (list) {
      if (query.isEmpty) return list;
      return list.where((s) => s.nama.toLowerCase().contains(query.toLowerCase())).toList();
    },
    orElse: () => [],
  );
});