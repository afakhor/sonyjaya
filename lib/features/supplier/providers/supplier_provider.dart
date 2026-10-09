import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';

// Provider DB - kalau sudah ada database_provider.dart pakai yang itu
final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

final supplierStreamProvider = StreamProvider<List<SupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.supplierDao.watchAll();
});

final hutangSupplierStreamProvider = StreamProvider<List<HutangSupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.hutangDao.watchAll();
});

// Helper warna tempo sesuai permintaan
// hitam <30 hari, kuning pas 30, hijau 31-59?, merah 60+
class HutangColorHelper {
  static Color getDotColor(HutangSupplierData h) {
    if (h.statusBayar == 'LUNAS') return const Color(0xFF10B981); // hijau lunas
    final now = DateTime.now();
    final diff = now.difference(h.tanggalNota).inDays;
    if (diff < 30) return const Color(0xFF0F172A); // hitam
    if (diff == 30) return const Color(0xFFF59E0B); // kuning pas 30
    if (diff >= 60) return const Color(0xFFEF4444); // merah 60+
    return const Color(0xFF22C55E); // hijau 31-59
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
