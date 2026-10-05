import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cache/isar_service.dart';
import '../../core/cache/models/fast_stock_cache.dart';
import '../../core/services/robotic_brain.dart';
import '../../core/services/auto_po_service.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../../core/database/local_database.dart';

final roboticBrainProvider = FutureProvider<Map<String,dynamic>>((ref) async {
  final db = ref.watch(localDbProvider);
  return await RoboticBrain.runFullAnalysis(db);
});

class AutoPoScreen extends ConsumerWidget {
  const AutoPoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brainAsync = ref.watch(roboticBrainProvider);
    final isarReorder = IsarService.watchPerluReorder();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Auto-PO & Fast Moving - Robotic Brain', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: brainAsync.when(
        data: (brain) {
          final summary = brain['summary'] as Map<String,dynamic>;
          final poList = brain['autoPo'] as List<Map<String,dynamic>>;
          
          return Column(
            children: [
              // SUMMARY SARAF
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(child: _summaryBox('${summary['totalSku']}', 'Total SKU', Colors.white)),
                    Expanded(child: _summaryBox('${summary['fastMoving']}', '🔥 FAST', const Color(0xFFF59E0B))),
                    Expanded(child: _summaryBox('${summary['kritis']}', '⚠️ Kritis', Colors.redAccent)),
                    Expanded(child: _summaryBox('${summary['kosong']}', 'Kosong', Colors.grey)),
                  ],
                ),
              ),
              
              // INFO ROBOTIC
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('TOR 30 hari | Keluar ${summary['totalKeluar30']} pcs | PO Saran ${summary['poSaran']} | Safety auto naik 1.5x jika FAST', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)))),
                    IconButton(icon: const Icon(Icons.refresh_rounded, size: 18), onPressed: ()=> ref.invalidate(roboticBrainProvider)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // LIST PO SARAF
              Expanded(
                child: poList.isEmpty 
                  ? StreamBuilder<List<FastStockCache>>(
                      stream: isarReorder,
                      builder: (c,snap){
                        if(!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final lr = snap.data!;
                        if(lr.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, size: 48, color: Colors.green.shade300), const SizedBox(height: 8), const Text('Semua stok aman', style: TextStyle(fontWeight: FontWeight.bold)), const Text('Tidak ada PO otomatis', style: TextStyle(fontSize: 12, color: Colors.grey))]));
                        return ListView.builder(padding: const EdgeInsets.all(12), itemCount: lr.length, itemBuilder: (ctx,i){
                          final item = lr[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: item.isFastMoving? Colors.red.shade200 : const Color(0xFFE2E8F0))),
                            child: ListTile(
                              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: item.isFastMoving? Colors.red.shade50 : Colors.amber.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(item.isFastMoving? Icons.local_fire_department_rounded : Icons.warning_rounded, color: item.isFastMoving? Colors.red : Colors.amber, size: 20)),
                              title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              subtitle: Text('Stok ${item.stok} | Safety ${item.safetyStock} | TOR ${item.tor.toStringAsFixed(2)} ${item.isFastMoving?"🔥":""}', style: const TextStyle(fontSize: 11)),
                              trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white), onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PO ${item.nama} qty ${item.safetyStock*2 - item.stok} dibuat!'))); }, child: const Text('Generate PO', style: TextStyle(fontSize: 11))),
                            ),
                          );
                        });
                      }
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12,0,12,100),
                      itemCount: poList.length,
                      separatorBuilder: (_,__)=> const SizedBox(height: 10),
                      itemBuilder: (c,i){
                        final m = poList[i];
                        final isFast = m['isFast'] as bool;
                        return Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isFast? Colors.red.shade200 : const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,3))]),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(m['nama'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)))),
                                  if(isFast) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)), child: const Text('FAST MOVING', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('SKU ${m['sku']??'-'} | Stok ${m['stokSisa']} / Safety ${m['safetyStock']} | TOR ${m['tor'].toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(6)), child: Text('Saran Order: ${m['saranQtyOrder']} Pcs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)))),
                                  const SizedBox(width: 8),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)), child: Text('Prioritas ${m['prioritas'].toStringAsFixed(1)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.visibility_rounded, size: 16), label: const Text('Detail', style: TextStyle(fontSize: 11)), onPressed: (){}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)))),
                                  const SizedBox(width: 8),
                                  Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.shopping_cart_rounded, size: 16), label: const Text('BUAT PO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)), onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PO ${m['nama']} qty ${m['saranQtyOrder']} dibuat!'))); })),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
        loading: ()=> const Center(child: CircularProgressIndicator()),
        error: (e,_ )=> Center(child: Text('Error Brain: $e')),
      ),
    );
  }

  Widget _summaryBox(String value, String label, Color color){
    return Column(children: [Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)), const SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w600))]);
  }
}
