import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../core/services/pelanggan_rating_service.dart';

class BukuPiutangScreen extends ConsumerStatefulWidget {
  const BukuPiutangScreen({super.key});
  @override ConsumerState<BukuPiutangScreen> createState()=> _BukuPiutangScreenState();
}

class _BukuPiutangScreenState extends ConsumerState<BukuPiutangScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override void initState(){ tab=TabController(length:3, vsync:this); super.initState(); }
  
  Future<void> _bayar(int id, double sisa) async {
    final ctrl=TextEditingController(text: sisa.toStringAsFixed(0));
    final bayar = await showDialog<double>(context: context, builder: (c)=> AlertDialog(
      title: const Text('Input Pembayaran (bisa cicil per tanggal)'),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Text('Sisa Rp $sisa'),
        TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah bayar hari ini', prefixIcon: Icon(Icons.payments_rounded))),
      ]),
      actions:[ElevatedButton(onPressed:()=>Navigator.pop(c,double.tryParse(ctrl.text)), child: const Text('Bayar'))],
    ));
    if(bayar!=null){ await ref.read(localDbProvider).piutangDao.bayarCicil(id, bayar, DateTime.now()); }
  }

  @override Widget build(BuildContext context){
    final db = ref.watch(localDbProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Buku Piutang - Pusat Pembeli', style: TextStyle(fontWeight: FontWeight.w800)), bottom: TabBar(controller: tab, tabs: const [Tab(text:'Prioritas Tagih'),Tab(text:'Rating Pembeli'),Tab(text:'Lunas Hijau')])),
      body: TabBarView(controller: tab, children:[
        StreamBuilder<List<PelangganPiutangData>>(stream: db.piutangDao.watchPrioritasTagih(), builder: (c,s){
          if(!s.hasData) return const Center(child: CircularProgressIndicator());
          final list=s.data!;
          if(list.isEmpty) return const Center(child: Text('Tidak ada piutang'));
          return ListView.builder(itemCount: list.length, padding: const EdgeInsets.all(8), itemBuilder: (c,i){
            final p=list[i]; final warna=PelangganRatingService.warnaPiutang(p.jatuhTempo, p.statusBayar); final lewat=DateTime.now().difference(p.jatuhTempo).inDays; final color=PelangganRatingService.colorWarna(warna);
            return Container(margin: const EdgeInsets.only(bottom:8), decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: color, width:6)), borderRadius: BorderRadius.circular(8)), child: ListTile(
              leading: Icon(warna=='HIJAU'? Icons.check_circle_rounded : Icons.warning_rounded, color: color),
              title: Text('${p.noNota} | ${p.pelangganNama} | Sisa Rp ${p.sisaPiutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:13)),
              subtitle: Text('Nota ${p.tanggalNota.toString().substring(0,10)} | Tempo ${p.jatuhTempo.toString().substring(0,10)} | ${warna} ${lewat<=0?'${-lewat} hari lagi':'Lewat $lewat hari'} | ${p.keterangan??''}\nDibayar Rp ${p.totalDibayar} / ${p.totalTagihan}', style: const TextStyle(fontSize:11)),
              trailing: ElevatedButton(onPressed:()=>_bayar(p.id, p.sisaPiutang), child: Text(warna=='MERAH_TUA'?'TAGIH!':'Bayar'), style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white)),
            ));
          });
        }),
        StreamBuilder<List<PelangganMasterData>>(stream: (db.select(db.pelangganMaster)..orderBy([(t)=> OrderingTerm.desc(t.skorRating)])).watch(), builder: (c,s){
          final list=s.data??[];
          return ListView.builder(itemCount: list.length, itemBuilder: (c,i){
            final pl=list[i];
            Color badge=pl.status=='TETAP'? Colors.green : pl.status=='BADDEBT'? Colors.red : pl.status=='PELANGGAN'? Colors.blue : Colors.grey;
            return ListTile(leading: Container(width:40,height:40,decoration: BoxDecoration(color: badge.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.person_rounded, color: badge)), title: Text('${pl.nama} [${pl.status}] Skor ${pl.skorRating.toStringAsFixed(1)}'), subtitle: Text('Belanja Rp ${pl.totalBelanja.toStringAsFixed(0)} | ${pl.frekuensi}x | ${pl.variasiBarang} macam | ${pl.totalQty} qty | Piutang aktif Rp ${pl.totalPiutangAktif.toStringAsFixed(0)}'), trailing: pl.status=='BADDEBT'? const Icon(Icons.block, color: Colors.red) : const Icon(Icons.star, color: Colors.amber));
          });
        }),
        StreamBuilder<List<PelangganPiutangData>>(stream: (db.select(db.pelangganPiutang)..where((p)=>p.statusBayar.equals('LUNAS'))..orderBy([(p)=> OrderingTerm.desc(p.tanggalLunas)])).watch(), builder: (c,s){
          final list=s.data??[];
          return ListView.builder(itemCount: list.length, itemBuilder: (c,i){ final p=list[i]; return ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text('${p.noNota} ${p.pelangganNama} Rp ${p.totalTagihan}'), subtitle: Text('Lunas ${p.tanggalLunas.toString().substring(0,16)} | Cicil ${p.totalDibayar} | ${p.keterangan??''}'), tileColor: Colors.green.shade50); });
        }),
      ]),
    );
  }
}