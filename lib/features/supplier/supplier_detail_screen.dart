import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';

class SupplierDetailScreen extends ConsumerStatefulWidget {
  final SupplierData supplier;
  const SupplierDetailScreen({super.key, required this.supplier});
  @override ConsumerState<SupplierDetailScreen> createState()=> _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  late SupplierData sup;
  @override void initState(){ sup=widget.supplier; super.initState(); }
  
  Future<void> _edit() async {
    final k=TextEditingController(text: sup.kontak??'');
    final a=TextEditingController(text: sup.alamat??'');
    final ket=TextEditingController(text: sup.keterangan??'');
    final top=TextEditingController(text: sup.topDefault.toString());
    final ok=await showDialog<bool>(context: context, builder: (c)=> AlertDialog(
      title: Text('Edit ${sup.nama}'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children:[
        TextField(controller: k, decoration: const InputDecoration(labelText:'Kontak HP/WA', prefixIcon: Icon(Icons.phone_rounded), border: OutlineInputBorder())),
        const SizedBox(height:10),
        TextField(controller: a, decoration: const InputDecoration(labelText:'Alamat', prefixIcon: Icon(Icons.location_on_rounded), border: OutlineInputBorder()), maxLines:2),
        const SizedBox(height:10),
        TextField(controller: ket, decoration: const InputDecoration(labelText:'Keterangan / TOP', hintText:'TOP 14 hari, sales Pak Budi', prefixIcon: Icon(Icons.note_rounded), border: OutlineInputBorder())),
        const SizedBox(height:10),
        TextField(controller: top, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'TOP Default hari', border: OutlineInputBorder())),
      ])), actions:[TextButton(onPressed:()=>Navigator.pop(c,false), child: const Text('Batal')), ElevatedButton(onPressed:()=>Navigator.pop(c,true), child: const Text('Simpan'))],
    ));
    if(ok==true){
      await ref.read(localDbProvider).supplierDao.updateKontakAlamat(sup.id, k.text, a.text, ket: ket.text, top: int.tryParse(top.text));
      final upd=await (ref.read(localDbProvider).select(ref.read(localDbProvider).supplier)..where((s)=>s.id.equals(sup.id))).getSingle();
      setState(()=>sup=upd);
    }
  }
  
  @override Widget build(BuildContext context){
    final db=ref.watch(localDbProvider);
    return Scaffold(appBar: AppBar(title: Text(sup.nama), actions:[IconButton(onPressed: _edit, icon: const Icon(Icons.edit_rounded))]),
      body: FutureBuilder<Map<String,dynamic>>(future: db.supplierDao.getInfoSupplier(sup.nama), builder: (c,s){
        if(!s.hasData) return const Center(child: CircularProgressIndicator());
        final d=s.data!;
        return ListView(padding: const EdgeInsets.all(14), children:[
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children:[
            Container(width:52,height:52,decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront_rounded, color: Color(0xFF2563EB), size:28)),
            const SizedBox(width:12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Text(sup.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize:16)),
              Text('Kontak: ${sup.kontak??'-'}', style: const TextStyle(fontSize:12)),
              Text('Alamat: ${sup.alamat??'-'}', style: const TextStyle(fontSize:12)),
              Text('Ket: ${sup.keterangan??'-'} | TOP ${sup.topDefault} hari', style: const TextStyle(fontSize:11, color: Colors.grey)),
            ])),
          ])),
          const SizedBox(height:12),
          Text('Total Belanja Rp ${d['totalBelanja']} | Hutang Rp ${d['totalHutang']} | ${d['jumlahTransaksi']}x transaksi'),
        ]);
      }),
    );
  }
}