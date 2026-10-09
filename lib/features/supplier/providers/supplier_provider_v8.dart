// FIX COMPAT: lib/features/supplier/providers/supplier_provider_v8.dart -> copy dari supplier_provider.dart
// Biar import lama '../supplier/providers/supplier_provider_v8.dart' tidak error
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';
export '../../inventory/providers/inventory_provider.dart' show localDbProvider;

final supplierStreamProvider = StreamProvider<List<SupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.supplierDao.watchAll();
});
final supplierListProvider = supplierStreamProvider;
class HutangColorHelper {
  static Color getDotColor(HutangSupplierData h) {
    if (h.statusBayar == 'LUNAS') return const Color(0xFF10B981);
    final diff = DateTime.now().difference(h.tanggalNota).inDays;
    if (diff < 30) return const Color(0xFF0F172A);
    if (diff == 30) return const Color(0xFFF59E0B);
    if (diff >= 60) return const Color(0xFFEF4444);
    return const Color(0xFF22C55E);
  }
  static String getLabel(HutangSupplierData h) {
    if (h.statusBayar == 'LUNAS') return 'LUNAS';
    final diff = DateTime.now().difference(h.tanggalNota).inDays;
    if (diff < 30) return 'TEMPO ${diff}h';
    if (diff == 30) return 'JATUH TEMPO HARI INI';
    if (diff >= 60) return 'OVERDUE ${diff}h';
    return 'TEMPO ${diff}h';
  }
}
class HutangWarna {
  static Color dot(HutangSupplierData h) => HutangColorHelper.getDotColor(h);
  static String label(HutangSupplierData h) => HutangColorHelper.getLabel(h);
}
