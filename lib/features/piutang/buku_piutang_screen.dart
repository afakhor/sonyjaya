import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../core/services/pelanggan_rating_service.dart';
import 'providers/piutang_provider.dart';

class BukuPiutangScreen extends ConsumerStatefulWidget {
  const BukuPiutangScreen({super.key});
  @override ConsumerState<BukuPiutangScreen> createState()=> _BukuPiutangScreenState();
}

class _BukuPiutangScreenState extends ConsumerState<BukuPiutangScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override void initState(){ tab=TabController(length:3, vsync:this); super.initState(); }
  @override void dispose(){ tab.dispose(); super.dispose(); }

  Future<void> _bayar(int id, double sisa) async {
    final ctrl=TextEditingController(text: sisa.toStringAsFixed(0));
    final bayar = await showDialog<double>(context: context, builder: (c)=> AlertDialog(
      title: const Text('Input Pembayaran (bisa cicil per tanggal)'),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Text('Sisa Rp ${sisa.toStringAsFixed(0)}'),
        const SizedBox(height:8),
        TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah bayar hari ini', prefixIcon: Icon(Icons.payments_rounded), border: OutlineInputBorder())),
      ]),
      actions:[TextButton(onPressed: ()=>Navigator.pop(c), child: const Text('Batal')), ElevatedButton(onPressed:()=>Navigator.pop(c,double.tryParse(ctrl.text)), child: const Text('Bayar'))],
    ));
    if(bayar!=null && bayar>0){ await ref.read(localDbProvider).piutangDao.bayarCicil(id, bayar, DateTime.now()); }
  }

  @override Widget build(BuildContext context){
    final db = ref.watch(localDbProvider);
    final piutangGroups = ref.watch(piutangListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buku Piutang - Pusat Pembeli', style: TextStyle(fontWeight: FontWeight.w800)), bottom: TabBar(controller: tab, tabs: const [Tab(text:'Prioritas Tagih'),Tab(text:'Rating Pembeli'),Tab(text:'Lunas Hijau')])),
      body: TabBarView(controller: tab, children:[
        // TAB 1 - PAKAI PROVIDER BARU (udah urut prioritas mana harus ditagih dulu)
        piutangGroups.when(
          loading: ()=> const Center(child: CircularProgressIndicator()),
          error: (e,_ )=> Center(child: Text('Error $e')),
          data: (groups){
            if(groups.isEmpty) return const Center(child: Text('Tidak ada piutang - semua HIJAU'));
            final allTrx = groups.expand((g)=> g.daftarTransaksi).toList();
            // sort lagi per nota (bukan per pelanggan) biar tau nota mana dulu yang harus dibayar
            allTrx.sort((a,b){
              final lewatA = DateTime.now().difference(a.jatuhTempo).inDays;
              final lewatB = DateTime.now().difference(b.jatuhTempo).inDays;
              final skorA = lewatA*0.7 + a.sisaPiutang/1e6*0.3;
              final skorB = lewatB*0.7 + b.sisaPiutang/1e6*0.3;
              return skorB.compareTo(skorA);
            });
            return ListView.builder(itemCount: allTrx.length, padding: const EdgeInsets.all(8), itemBuilder: (c,i){
              final p=allTrx[i]; final warna=PelangganRatingService.warnaPiutang(p.jatuhTempo, p.statusBayar); final lewat=DateTime.now().difference(p.jatuhTempo).inDays; final color=PelangganRatingService.colorWarna(warna);
              return Container(margin: const EdgeInsets.only(bottom:8), decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: color, width:6)), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]), child: ListTile(
                leading: Icon(warna=='HIJAU'? Icons.check_circle_rounded : warna=='MERAH_TUA'? Icons.block : Icons.warning_rounded, color: color),
                title: Text('${p.noNota} | ${p.pelangganNama} | Sisa Rp ${p.sisaPiutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:13)),
                subtitle: Text('Nota ${p.tanggalNota.toString().substring(0,10)} | Tempo ${p.jatuhTempo.toString().substring(0,10)} | $warna ${lewat<=0?'${-lewat} hari lagi':'Lewat $lewat hari'} | ${p.keterangan??''}\nDibayar Rp ${p.totalDibayar} / ${p.totalTagihan}', style: const TextStyle(fontSize:11)),
                trailing: ElevatedButton(onPressed:()=>_bayar(p.id, p.sisaPiutang), child: Text(warna=='MERAH_TUA'?'TAGIH!':'Bayar', style: const TextStyle(fontSize:11)), style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white)),
              ));
            });
          }
        ),
        // TAB 2 - RATING PEMBELI
        StreamBuilder<List<PelangganMasterData>>(stream: (db.select(db.pelangganMaster)..orderBy([(t)=> OrderingTerm.desc(t.skorRating)])).watch(), builder: (c,s){
          final list=s.data??[];
          if(list.isEmpty) return const Center(child: Text('Belum ada pelanggan - transaksi di Kasir dulu'));
          return ListView.builder(itemCount: list.length, itemBuilder: (c,i){
            final pl=list[i];
            Color badge=pl.status=='TETAP'? Colors.green : pl.status=='BADDEBT'? Colors.red : pl.status=='PELANGGAN'? Colors.blue : Colors.grey;
            return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: ListTile(
              leading: Container(width:40,height:40,decoration: BoxDecoration(color: badge.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.person_rounded, color: badge)),
              title: Text('${pl.nama} [${pl.status}] Skor ${pl.skorRating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:13)),
              subtitle: Text('Belanja Rp ${pl.totalBelanja.toStringAsFixed(0)} | ${pl.frekuensi}x beli | ${pl.variasiBarang} macam | ${pl.totalQty} qty | Piutang aktif Rp ${pl.totalPiutangAktif.toStringAsFixed(0)}', style: const TextStyle(fontSize:11)),
              trailing: pl.status=='BADDEBT'? const Icon(Icons.block, color: Colors.red) : pl.status=='TETAP'? const Icon(Icons.star, color: Colors.amber) : const Icon(Icons.person_outline),
            ));
          });
        }),
        // TAB 3 - LUNAS HIJAU
        StreamBuilder<List<PelangganPiutangData>>(stream: (db.select(db.pelangganPiutang)..where((p)=>p.statusBayar.equals('LUNAS'))..orderBy([(p)=> OrderingTerm.desc(p.tanggalLunas)])).watch(), builder: (c,s){
          final list=s.data??[];
          if(list.isEmpty) return const Center(child: Text('Belum ada yang lunas HIJAU'));
          return ListView.builder(itemCount: list.length, itemBuilder: (c,i){ final p=list[i]; return ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text('${p.noNota} ${p.pelangganNama} Rp ${p.totalTagihan.toStringAsFixed(0)}', style: const TextStyle(fontSize:13)), subtitle: Text('Lunas ${p.tanggalLunas?.toString().substring(0,16)??'-'} | Cicil total Rp ${p.totalDibayar.toStringAsFixed(0)} | ${p.keterangan??''}', style: const TextStyle(fontSize:11)), tileColor: Colors.green.shade50); });
        }),
      ]),
    );
  }
}