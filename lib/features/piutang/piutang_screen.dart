import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/piutang_provider.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../core/services/pelanggan_rating_service.dart';

class PiutangScreen extends ConsumerWidget {
  const PiutangScreen({super.key});

  Future<void> _bayarCicil(BuildContext context, WidgetRef ref, PelangganPiutangData p) async {
    final ctrl = TextEditingController(text: p.sisaPiutang.toStringAsFixed(0));
    final bayar = await showDialog<double>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Bayar ${p.noNota} - ${p.pelangganNama}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Sisa Rp ${p.sisaPiutang.toStringAsFixed(0)} | Tempo ${p.jatuhTempo.toString().substring(0,10)}'),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah bayar hari ini', prefixIcon: Icon(Icons.payments_rounded), border: OutlineInputBorder())),
        ]),
        actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: const Text('Batal')), ElevatedButton(onPressed: ()=>Navigator.pop(c, double.tryParse(ctrl.text)), child: const Text('Bayar'))],
      ),
    );
    if (bayar!= null && bayar > 0) {
      await ref.read(localDbProvider).piutangDao.bayarCicil(p.id, bayar, DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piutangAsync = ref.watch(piutangListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Piutang Pelanggan'), elevation: 1),
      body: piutangAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Gagal memuat: $err', style: const TextStyle(color: Colors.red)))),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline, size: 64, color: Colors.green), SizedBox(height: 12), Text('Tidak ada piutang aktif.', style: TextStyle(fontSize: 16, color: Colors.grey))]));
          }
          final grandTotal = groups.fold<double>(0, (sum, item) => sum + item.totalPiutang);
          return Column(children: [
            Container(width: double.infinity, padding: const EdgeInsets.all(16), color: Colors.orange.shade50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total Piutang Pelanggan', style: TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.w500)), Text('${groups.length} Pelanggan (${groups.fold<int>(0, (sum, g) => sum + g.jumlahNota)} Nota)', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              Text('Rp ${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ])),
            const Divider(height: 1),
            Expanded(child: ListView.builder(itemCount: groups.length, itemBuilder: (context, index) {
              final group = groups[index];
              final color = PelangganRatingService.colorWarna(group.statusWarna);
              return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: ExpansionTile(
                leading: CircleAvatar(backgroundColor: color, child: Icon(group.statusWarna=='MERAH_TUA'? Icons.block : Icons.person, color: Colors.white, size: 20)),
                title: Text(group.namaPelanggan, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${group.jumlahNota} Nota | ${group.statusWarna} ${group.maxLewatHari>0? 'Lewat ${group.maxLewatHari} hari' : '${-group.maxLewatHari} hari lagi'}', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
                trailing: Text('Rp ${group.totalPiutang.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                children: group.daftarTransaksi.map((trx) {
                  final warnaTrx = PelangganRatingService.warnaPiutang(trx.jatuhTempo, trx.statusBayar);
                  final cTrx = PelangganRatingService.colorWarna(warnaTrx);
                  final lewat = DateTime.now().difference(trx.jatuhTempo).inDays;
                  return Container(color: warnaTrx=='HIJAU'? Colors.green.shade50 : warnaTrx=='MERAH_TUA'? Colors.red.shade50 : Colors.grey.shade50, child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Icon(Icons.receipt_long_rounded, color: cTrx),
                    title: Text('${trx.noNota} (${trx.statusBayar}) - ${warnaTrx}', style: TextStyle(fontWeight: FontWeight.bold, color: cTrx, fontSize: 12)),
                    subtitle: Text('Total Rp ${trx.totalTagihan.toStringAsFixed(0)} | Sisa Rp ${trx.sisaPiutang.toStringAsFixed(0)}\nNota ${trx.tanggalNota.toString().substring(0,10)} | Tempo ${trx.jatuhTempo.toString().substring(0,10)} | ${trx.keterangan??''}\nDibayar Rp ${trx.totalDibayar}', style: const TextStyle(fontSize: 11)),
                    isThreeLine: true,
                    trailing: ElevatedButton(onPressed: ()=> _bayarCicil(context, ref, trx), style: ElevatedButton.styleFrom(backgroundColor: cTrx, foregroundColor: Colors.white, minimumSize: const Size(60, 30)), child: Text(warnaTrx=='MERAH_TUA'?'TAGIH':'Bayar', style: const TextStyle(fontSize: 11))),
                  ));
                }).toList(),
              ));
            })),
          ]);
        },
      ),
    );
  }
}