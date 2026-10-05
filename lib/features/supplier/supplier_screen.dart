import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../core/services/robotic_brain.dart';
import 'supplier_detail_screen.dart';

class SupplierScreen extends ConsumerWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(allSupplierStreamProvider);
    final brainAsync = ref.watch(roboticBrainProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Master Supplier - Robotic Brain', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.analytics_rounded), onPressed: ()=> ref.invalidate(roboticBrainProvider), tooltip: 'Refresh Brain'),
        ],
      ),
      body: Column(
        children: [
          // ROBOTIC BRAIN HEADER
          brainAsync.when(
            data: (brain){
              final summary = brain['summary'] as Map<String,dynamic>;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    const Icon(Icons.memory_rounded, size: 18, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Brain: ${summary['totalSku']} SKU terdeteksi | Supplier auto-sync saat input nota HPP + TOR 30 hari', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  ],
                ),
              );
            },
            loading: ()=> const SizedBox(),
            error: (_,__)=> const SizedBox(),
          ),

          Expanded(
            child: supplierAsync.when(
              data: (list){
                if(list.isEmpty){
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('Belum ada supplier.', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Supplier otomatis ke-simpan saat\nkamu input barang masuk + HPP\n+ Robotic Brain sync', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(icon: const Icon(Icons.add_rounded), label: const Text('Input Nota Sekarang'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white), onPressed: (){}),
                  ]));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12,0,12,100),
                  itemCount: list.length,
                  separatorBuilder: (_,__)=> const SizedBox(height: 10),
                  itemBuilder: (c,i){
                    final s = list[i];
                    return FutureBuilder<Map<String,dynamic>>(
                      future: ref.read(localDbProvider).supplierDao.getInfoSupplier(s.nama),
                      builder: (context,snap){
                        final totalBelanja = snap.data?['totalBelanja']??0.0;
                        final totalHutang = snap.data?['totalHutang']??0.0;
                        final jumlahTx = snap.data?['jumlahTransaksi']??0;
                        final daftarBarang = snap.data?['daftarBarang'] as List<BarangData>? ?? [];
                        
                        // ROBOTIC: deteksi apakah supplier ini supply barang fast moving
                        final isFastSupplier = snap.connectionState==ConnectionState.done && daftarBarang.any((b)=> b.stok<=b.safetyStock);

                        return InkWell(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> SupplierDetailScreen(supplier: s))),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isFastSupplier? Colors.orange.shade200 : const Color(0xFFE2E8F0)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,3))],
                            ),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isFastSupplier? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(10)), child: Icon(isFastSupplier? Icons.local_fire_department_rounded : Icons.store_rounded, color: isFastSupplier? const Color(0xFFD97706) : const Color(0xFF2563EB))),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(child: Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
                                        if(isFastSupplier) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)), child: const Text('FAST', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))),
                                      ]),
                                      const SizedBox(height: 2),
                                      Text(s.kontak??'- | ${s.alamat??'-'}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        _chip('Belanja Rp ${totalBelanja.toStringAsFixed(0)}', const Color(0xFFF0FDF4), const Color(0xFF15803D)),
                                        const SizedBox(width: 6),
                                        if(totalHutang>0) _chip('Hutang Rp ${totalHutang.toStringAsFixed(0)}', const Color(0xFFFEF2F2), const Color(0xFFB91C1C)) else _chip('$jumlahTx tx', const Color(0xFFF1F5F9), Colors.black54),
                                      ]),
                                      if(daftarBarang.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text('Supply: ${daftarBarang.take(3).map((b)=>b.nama).join(', ')}${daftarBarang.length>3?' +${daftarBarang.length-3} lagi':''}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: ()=> const Center(child: CircularProgressIndicator()),
              error: (e,_)=> Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        onPressed: ()=> ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier otomatis dari Nota Masuk + HPP - Robotic Brain'))),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Robotic Sync', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg){
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)));
  }
}

// Provider yang dipakai kedua screen
final roboticBrainProvider = FutureProvider<Map<String,dynamic>>((ref) async {
  final db = ref.watch(localDbProvider);
  return await RoboticBrain.runFullAnalysis(db);
});
