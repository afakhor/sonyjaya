import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../../core/services/auto_po_service.dart';

// Provider instance database lokal
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

// Provider untuk mengambil daftar draft PO otomatis
final autoPoDraftProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(localDatabaseProvider);
  return await AutoPoService.generateDraftPo(db);
});
