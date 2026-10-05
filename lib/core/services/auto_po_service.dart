import '../database/local_database.dart';
import '../cache/isar_service.dart';
class AutoPoService {
  static Future<List<Map<String,dynamic>>> generateDraftPo(LocalDatabase db) async {
    final barangs = await db.select(db.barang).get();
    final cacheList = await IsarService.getAllCache();
    final List<Map<String,dynamic>> draftList=[];
    for(final b in barangs){
      final cache = cacheList.where((c)=>c.barangId==b.id).firstOrNull;
      final perlu = cache?.perluReorder?? (b.stok<=b.safetyStock);
      if(perlu){
        final qtySaran = cache!=null && cache.tor>2.5? (b.safetyStock*3 - b.stok) : (b.safetyStock*2 - b.stok);
        draftList.add({'barangId':b.id,'nama':b.nama,'sku':b.sku,'stokSisa':b.stok,'safetyStock':b.safetyStock,'tor':cache?.tor??0,'isFast':cache?.isFastMoving??false,'saranQtyOrder':qtySaran<5?5:qtySaran,'prioritas':cache?.priorityScore??0});
      }
    }
    draftList.sort((a,b)=> (b['prioritas'] as double).compareTo(a['prioritas'] as double));
    return draftList;
  }
}
