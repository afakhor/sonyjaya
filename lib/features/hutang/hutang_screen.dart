// FILE 5/5 - lib/features/hutang/hutang_screen.dart - FINAL MERGED
// Gabung PO-based lama + Nota-based baru + warna tempo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../supplier/providers/supplier_provider_v8.dart';
import 'providers/hutang_provider.dart'; // provider lama kamu tetap

final hutangNotaProvider = StreamProvider<List<HutangSupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.hutangDao.watchAll();
});

class HutangWarna {
  static Color dot(HutangSupplierData h) {
    if (h.statusBayar == 'LUNAS') return const Color(0xFF10B981);
    final diff = DateTime.now().difference(h.tanggalNota).inDays;
    if (diff < 30) return const Color(0xFF0F172A); // hitam
    if (diff == 30) return const Color(0xFFF59E0B); // kuning pas 30
    if (diff >= 60) return const Color(0xFFEF4444); // merah 60
    return const Color(0xFF22C55E); // hijau 31-59
  }
  static String label(HutangSupplierData h) {
    if (h.statusBayar == 'LUNAS') return 'LUNAS';
    final diff = DateTime.now().difference(h.tanggalNota).inDays;
    if (diff < 30) return 'HITAM <30h';
    if (diff == 30) return 'KUNING 30h';
    if (diff >= 60) return 'MERAH ${diff}h';
    return 'HIJAU ${diff}h';
  }
}

class HutangScreen extends ConsumerWidget {
  const HutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hutangAsync = ref.watch(hutangListProvider); // PO lama tetap
    final notaAsync = ref.watch(hutangNotaProvider); // Nota baru kuning

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Daftar Hutang Supplier'), backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=>Navigator.pop(context))),
      body: notaAsync.when(
        data: (notaList) {
          if (notaList.isEmpty) {
            // fallback ke data lama kalau nota masih kosong
            return hutangAsync.when(
              data: (listHutang) {
                if (listHutang.isEmpty) return const Center(child: Text('Tidak ada hutang supplier.'));
                return _buildGroupedBySupplier(context, ref, listHutang, notaList);
              },
              loading: ()=>const Center(child: CircularProgressIndicator()),
              error: (e,_ )=>Center(child: Text('Error $e')),
            );
          }
          // Group nota per supplier untuk ExpansionTile
          final Map<String, List<HutangSupplierData>> grouped = {};
          for(var h in notaList){ grouped.putIfAbsent(h.supplierNama, ()=>[]).add(h); }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.keys.length,
            itemBuilder: (_, idx){
              final supplierNama = grouped.keys.elementAt(idx);
              final list = grouped[supplierNama]!;
              final totalHutang = list.fold<double>(0, (s,h)=> s + h.sisaHutang);
              final jumlahPo = list.length;
              return Container(
                margin: const EdgeInsets.only(bottom:12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: ExpansionTile(
                  title: Text(supplierNama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$jumlahPo Nota • ${list.where((h)=>h.statusBayar!='LUNAS').length} belum lunas'),
                  trailing: Text('Rp ${totalHutang.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: totalHutang>0?Colors.red:Colors.green, fontSize:16)),
                  children: list.map((h){
                    final c = HutangWarna.dot(h);
                    final l = HutangWarna.label(h);
                    return ListTile(
                      dense:true,
                      leading: Container(width:10,height:10,decoration: BoxDecoration(color:c,shape:BoxShape.circle)),
                      title: Text('${h.noNota} • ${h.tipeBayar}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize:13)),
                      subtitle: Text('Tgl ${h.tanggalNota.day}/${h.tanggalNota.month} • Tempo ${h.jatuhTempo.day}/${h.jatuhTempo.month} • TOP ${h.topDays}h • $l', style: const TextStyle(fontSize:11)),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children:[
                        Text('Rp ${h.totalTagihan.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:12)),
                        Text('Sisa Rp ${h.sisaHutang.toStringAsFixed(0)}', style: TextStyle(fontSize:11, color: h.sisaHutang>0?Colors.red:Colors.green)),
                      ]),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
        loading: ()=>const Center(child: CircularProgressIndicator()),
        error: (e,_)=>Center(child: Text('Error $e')),
      ),
    );
  }

  Widget _buildGroupedBySupplier(BuildContext context, WidgetRef ref, List<dynamic> listHutang, List<HutangSupplierData> notaList){
    return ListView.builder(
      itemCount: listHutang.length,
      itemBuilder: (context, index) {
        final hutang = listHutang[index];
        return ExpansionTile(
          title: Text(hutang.namaSupplier, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${hutang.jumlahPo} PO Belum Lunas'),
          trailing: Text('Rp ${hutang.totalHutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize:16)),
          children: hutang.daftarPo.map<Widget>((po){
            final tgl = po.tanggalPo.toLocal().toString().split('.')[0];
            return ListTile(dense:true, title: Text('PO #${po.id} - $tgl'), subtitle: Text('Status: ${po.statusBayar}'), trailing: Text('Rp ${po.totalKeseluruhan.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)));
          }).toList(),
        );
      },
    );
  }
}
