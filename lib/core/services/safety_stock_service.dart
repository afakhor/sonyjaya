import '../database/local_database.dart';
class SafetyStockService {
  static Future<List<Map<String,dynamic>>> analisaSafetyStock(LocalDatabase db) async {
    final barangs = await db.select(db.barang).get();
    final List<Map<String,dynamic>> result=[];
    for(final b in barangs){
      final batas = DateTime.now().subtract(const Duration(days:30));
      final logs = await (db.select(db.kartuStok)..where((k)=>k.barangId.equals(b.id))..where((k)=>k.tipe.equals('KELUAR'))..where((k)=>k.tanggal.isBiggerThanValue(batas))).get();
      final keluar = logs.fold<int>(0, (s,e)=>s+e.qty.abs());
      final tor = b.stok==0?0.0:keluar/b.stok;
      final saranSafety = keluar==0? b.safetyStock : (keluar/30*7).ceil();
      result.add({'barang':b,'tor':tor,'keluar30':keluar,'safetyLama':b.safetyStock,'safetySaran':saranSafety,'status': b.stok<=0?'KOSONG': b.stok<=b.safetyStock?'KRITIS': tor>2.5?'FAST MOVING':'AMAN','qtyOrderSaran': (saranSafety*2 - b.stok).clamp(5,100)});
    }
    return result;
  }
}
