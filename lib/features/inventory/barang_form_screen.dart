// lib/features/inventory/barang_form_screen.dart - FINAL VARIASI + HARGA ECER/AGEN/MANUAL - TANPA DUMMY
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangFormScreen extends ConsumerStatefulWidget {
  const BarangFormScreen({super.key});
  @override ConsumerState<BarangFormScreen> createState() => _BarangFormScreenState();
}

class _BarangFormScreenState extends ConsumerState<BarangFormScreen> {
  final namaCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final merekCtrl = TextEditingController();
  final stokCtrl = TextEditingController(text:"0");
  final hppCtrl = TextEditingController(text:"0");
  final ecerCtrl = TextEditingController(text:"0");
  final agenCtrl = TextEditingController(text:"0");
  final safetyCtrl = TextEditingController(text:"2");

  List<Map<String,TextEditingController>> variasis = [];

  @override void initState(){
    super.initState();
    _addVariasi(); // start 1 kosong, bukan dummy KAOS
  }

  void _addVariasi(){
    setState((){
      variasis.add({
        "nama": TextEditingController(),
        "sku": TextEditingController(),
        "stok": TextEditingController(text:"0"),
        "hpp": TextEditingController(text:"0"),
        "ecer": TextEditingController(text:"0"),
        "agen": TextEditingController(text:"0"),
        "manual": TextEditingController(text:"0"),
      });
    });
  }

  double _margin(double hpp, double jual){
    if(hpp==0 || jual==0) return 0;
    return ((jual-hpp)/hpp*100);
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text("Input Barang Baru"), backgroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Data Barang Utama", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height:8),
        TextField(controller: namaCtrl, decoration: const InputDecoration(labelText:"Nama Barang", border: OutlineInputBorder(), isDense:true)),
        const SizedBox(height:8),
        Row(children: [
          Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText:"SKU", border: OutlineInputBorder(), isDense:true))),
          const SizedBox(width:8),
          Expanded(child: TextField(controller: merekCtrl, decoration: const InputDecoration(labelText:"Merek", border: OutlineInputBorder(), isDense:true))),
        ]),
        const SizedBox(height:8),
        Row(children: [
          Expanded(child: TextField(controller: stokCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Stok", border: OutlineInputBorder(), isDense:true))),
          const SizedBox(width:8),
          Expanded(child: TextField(controller: hppCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"HPP / Harga Beli", border: OutlineInputBorder(), isDense:true))),
        ]),
        const SizedBox(height:8),
        Row(children: [
          Expanded(child: TextField(controller: ecerCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Harga Ecer", border: OutlineInputBorder(), isDense:true))),
          const SizedBox(width:8),
          Expanded(child: TextField(controller: agenCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Harga Agen", border: OutlineInputBorder(), isDense:true))),
        ]),
        const SizedBox(height:16),
        // Variasi hijau
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Input Variasi + Harga (${variasis.length} SKU)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16)),
              TextButton(onPressed: _addVariasi, child: const Text("+ Tambah Variasi")),
            ]),
            ...List.generate(variasis.length, (i){
              final v = variasis[i];
              return Container(
                margin: const EdgeInsets.only(bottom:12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Variasi #${i+1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    InkWell(onTap: ()=> setState(()=> variasis.removeAt(i)), child: const Text("Hapus", style: TextStyle(color: Colors.red, fontSize:12))),
                  ]),
                  const SizedBox(height:8),
                  TextField(controller: v["nama"]!, decoration: const InputDecoration(labelText:"Nama Variasi", border: OutlineInputBorder(), isDense:true)),
                  const SizedBox(height:8),
                  Row(children: [
                    Expanded(child: TextField(controller: v["sku"]!, decoration: const InputDecoration(labelText:"SKU Variasi", border: OutlineInputBorder(), isDense:true))),
                    const SizedBox(width:8),
                    Expanded(child: TextField(controller: v["stok"]!, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Stok", border: OutlineInputBorder(), isDense:true))),
                  ]),
                  const SizedBox(height:8),
                  TextField(controller: v["hpp"]!, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"HPP / Harga Beli", border: OutlineInputBorder(), isDense:true)),
                  const SizedBox(height:8),
                  Row(children: [
                    Expanded(child: _priceBox("Harga Ecer", v["ecer"]!, v["hpp"]!, const Color(0xFFFFF7ED))),
                    const SizedBox(width:6),
                    Expanded(child: _priceBox("Harga Agen", v["agen"]!, v["hpp"]!, const Color(0xFFEFF6FF))),
                    const SizedBox(width:6),
                    Expanded(child: _priceBox("Harga Manual", v["manual"]!, v["hpp"]!, const Color(0xFFF9FAFB))),
                  ]),
                ]),
              );
            }),
            // Nota Masuk Harga Bertingkat
            const SizedBox(height:16),
            const Text("Nota Masuk — Harga Bertingkat", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Preview harga jual per variasi.", style: TextStyle(fontSize:11,color: Colors.black54)),
            const SizedBox(height:8),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(top: Radius.circular(12))), child: const Row(children: [Expanded(child: Text("BARANG", style: TextStyle(color: Colors.white,fontSize:11))), SizedBox(width:40, child: Text("QTY", style: TextStyle(color: Colors.white,fontSize:11))), Expanded(child: Text("HARGA JUAL", style: TextStyle(color: Colors.white,fontSize:11)))])),
                ...variasis.map((v)=> Padding(padding: const EdgeInsets.all(8), child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v["nama"]!.text.isEmpty? "—": v["nama"]!.text, style: const TextStyle(fontSize:12,fontWeight: FontWeight.bold)), Text("HPP Rp ${v["hpp"]!.text}", style: const TextStyle(fontSize:10,color: Colors.black54))])),
                  SizedBox(width:40, child: Text(v["stok"]!.text, style: const TextStyle(fontSize:12))),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text("Ecer Rp ${v["ecer"]!.text}", style: const TextStyle(fontSize:11)),
                    Text("Agen Rp ${v["agen"]!.text}", style: const TextStyle(fontSize:11,color: Colors.blue)),
                    Text("Manual ${v["manual"]!.text.isEmpty? "-": "Rp ${v["manual"]!.text}"}", style: const TextStyle(fontSize:11)),
                  ])),
                ]))),
              ]),
            ),
          ]),
        ),
        const SizedBox(height:20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _simpan, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical:14)), child: const Text("Simpan Barang"))),
      ])),
    );
  }

  Widget _priceBox(String label, TextEditingController ctrl, TextEditingController hppCtrl, Color bg){
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize:10,fontWeight: FontWeight.bold)),
        const SizedBox(height:4),
        TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense:true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal:8,vertical:6)), style: const TextStyle(fontSize:12)),
        const SizedBox(height:4),
        ValueListenableBuilder(valueListenable: ctrl, builder: (ctx,_,__){
          final hpp = double.tryParse(hppCtrl.text)??0;
          final jual = double.tryParse(ctrl.text)??0;
          final m = _margin(hpp,jual);
          return Text("Margin ${m.toStringAsFixed(1)}%", style: const TextStyle(fontSize:10,color: Colors.black54));
        }),
      ]),
    );
  }

  Future<void> _simpan() async {
    final db = ref.read(localDbProvider);
    final inv = ref.read(inventoryControllerProvider);
    // Simpan barang utama
    final barangId = await db.barangDao.insertBarang(BarangCompanion.insert(
      sku: skuCtrl.text.isEmpty? "SKU-${DateTime.now().millisecondsSinceEpoch}" : skuCtrl.text,
      nama: namaCtrl.text,
      merek: Value(merekCtrl.text),
      stok: Value(int.tryParse(stokCtrl.text)??0),
      hppAverage: Value(double.tryParse(hppCtrl.text)??0),
      hargaEcer: Value(double.tryParse(ecerCtrl.text)??0),
      hargaAgen: Value(double.tryParse(agenCtrl.text)??0),
    ));
    // Simpan variasi
    for(var v in variasis){
      if(v["nama"]!.text.isEmpty) continue;
      await db.barangDao.insertVariasi(BarangVariasiCompanion.insert(
        barangId: barangId,
        variasiNama: v["nama"]!.text,
        skuVariasi: Value(v["sku"]!.text),
        stok: Value(int.tryParse(v["stok"]!.text)??0),
        hargaEcer: Value(double.tryParse(v["ecer"]!.text)),
        hargaAgen: Value(double.tryParse(v["agen"]!.text)),
        keterangan: Value(v["manual"]!.text.isEmpty? null : "Manual:${v["manual"]!.text}"),
      ));
    }
    await inv.refreshAll();
    if(mounted) Navigator.pop(context);
  }
}
