import '../database/local_database.dart';
import '../cache/isar_service.dart';
import 'auto_po_service.dart';
import 'safety_stock_service.dart';
class RoboticBrain {
  static Future<Map<String,dynamic>> runFullAnalysis(LocalDatabase db) async {
    await IsarService.init();
    final safety = await SafetyStockService.analisaSafetyStock(db);
    final po = await AutoPoService.generateDraftPo(db);
    final fastCount = safety.where((e)=>e['status']=='FAST MOVING').length;
    final kritisCount = safety.where((e)=>e['status']=='KRITIS').length;
    final kosongCount = safety.where((e)=>e['status']=='KOSONG').length;
    final totalKeluar30 = safety.fold<int>(0, (s,e)=>s+(e['keluar30'] as int));
    return {'timestamp': DateTime.now(),'safetyAnalysis': safety,'autoPo': po,'summary': {'fastMoving': fastCount,'kritis': kritisCount,'kosong': kosongCount,'totalKeluar30': totalKeluar30,'totalSku': safety.length,'poSaran': po.length,}};
  }
}
