import '../database/local_database.dart';

class AutoPoService {
  static Future<List<Map<String, dynamic>>> generateDraftPo(LocalDatabase db) async {
    // FIX: Gunakan isSmallerOrEqualValue
    final barangs = await (db.select(db.barang)..where((b) => b.stok.isSmallerOrEqualValue(b.safetyStock))).get();
    
    final List<Map<String, dynamic>> draftList = [];
    for (final b in barangs) {
      final qtySaran = (b.safetyStock * 2) - b.stok;
      draftList.add({
        'barangId': b.id,
        'nama': b.nama,
        'stokSisa': b.stok,
        'safetyStock': b.safetyStock,
        'saranQtyOrder': qtySaran < 5 ? 5 : qtySaran,
      });
    }
    return draftList;
  }
}
