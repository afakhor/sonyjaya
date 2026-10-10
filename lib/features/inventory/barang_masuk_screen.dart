// lib/features/inventory/barang_masuk_screen.dart - FINAL NOTA MASUK + HARGA BERTINGKAT + VARIASI - TANPA DUMMY
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangMasukScreen extends ConsumerStatefulWidget {
  const BarangMasukScreen({super.key});
  @override ConsumerState<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends ConsumerState<BarangMasukScreen> {
  final noNotaCtrl = TextEditingController();
  final supplierCtrl = TextEditingController();
  String tipeBayar = "TEMPO";
  List<Map<String,dynamic>> items = []; // {barangId, qty, hpp, ecer, agen, manual}

  @override void initState(){
    super.initState();
    items.add({"barangId": null, "qty":1, "hpp":0.0, "ecer":0.0, "agen":0.0, "manual":0.0});
  }

  @override Widget build(BuildContext context){
    final barangList = ref.watch(barangListProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text("Nota Masuk + HPP Auto"), backgroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: noNotaCtrl, decoration: const InputDecoration(labelText:"No Nota", border: OutlineInputBorder(), isDense:true)),
        const SizedBox(height:8),
        TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText:"Supplier", border: OutlineInputBorder(), isDense:true)),
        const SizedBox(height:8),
        DropdownButtonFormField(value: tipeBayar, items: const [DropdownMenuItem(value:"TEMPO", child: Text("TEMPO")), DropdownMenuItem(value:"LUNAS", child: Text("LUNAS"))], onChanged: (v)=> setState(()=> tipeBayar=v!), decoration: const InputDecoration(border: OutlineInputBorder(), isDense:true, labelText:"Tipe Bayar")),
        const SizedBox(height:16),
        // Variasi barang masuk
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Nota Masuk — Harga Bertingkat", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16)),
            const Text("Input saat barang datang, bisa manual override harga jual.", style: TextStyle(fontSize:11,color: Colors.black54)),
            const SizedBox(height:12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              child: const Row(children: [Expanded(flex:2, child: Text("BARANG", style: TextStyle(color: Colors.white,fontSize:11))), SizedBox(width:50, child: Text("QTY", style: TextStyle(color: Colors.white,fontSize:11))), Expanded(child: Text("HARGA JUAL", style: TextStyle(color: Colors.white,fontSize:11)))]),
            ),
            ...List.generate(items.length, (i){
              final it = items[i];
              return Padding(padding: const EdgeInsets.symmetric(vertical:6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex:2, child: Column(children: [
                  DropdownButtonFormField<int>(value: it["barangId"], hint: const Text("Pilih Barang", style: TextStyle(fontSize:11)), isDense:true, items: barangList.when(data:(list)=> list.map((b)=> DropdownMenuItem(value:b.id, child: Text("${b.nama} - ${b.sku}", style: const TextStyle(fontSize:11)))).toList(), loading:()=>[], error:(_,__ )=>[]), onChanged: (v)=> setState(()=> items[i]["barangId"]=v)),
                  const SizedBox(height:4),
                  TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"HPP", border: OutlineInputBorder(), isDense:true), onChanged: (v)=> setState(()=> items[i]["hpp"]=double.tryParse(v)??0)),
                ])),
                const SizedBox(width:6),
                SizedBox(width:50, child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), isDense:true), controller: TextEditingController(text: it["qty"].toString()), onChanged: (v)=> setState(()=> items[i]["qty"]=int.tryParse(v)??1))),
                const SizedBox(width:6),
                Expanded(child: Column(children: [
                  TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Ecer", border: OutlineInputBorder(), isDense:true), onChanged: (v)=> setState(()=> items[i]["ecer"]=double.tryParse(v)??0)),
                  const SizedBox(height:4),
                  TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Agen", border: OutlineInputBorder(), isDense:true), onChanged: (v)=> setState(()=> items[i]["agen"]=double.tryParse(v)??0)),
                  const SizedBox(height:4),
                  TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:"Manual", border: OutlineInputBorder(), isDense:true), onChanged: (v)=> setState(()=> items[i]["manual"]=double.tryParse(v)??0)),
                  Text("Margin Ecer ${it["hpp"]==0?0:(((it["ecer"]-it["hpp"])/it["hpp"]*100).toStringAsFixed(1))}%", style: const TextStyle(fontSize:9,color: Colors.black54)),
                ])),
              ]));
            }),
            const SizedBox(height:8),
            OutlinedButton(onPressed: ()=> setState(()=> items.add({"barangId": null, "qty":1, "hpp":0.0, "ecer":0.0, "agen":0.0, "manual":0.0})), child: const Text("+ Tambah Barang")),
          ]),
        ),
        const SizedBox(height:20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () async {
            final db = ref.read(localDbProvider);
            final inv = ref.read(inventoryControllerProvider);
            await db.transaction(() async {
              for(var it in items){
                if(it["barangId"]==null) continue;
                final barangId = it["barangId"] as int;
                final qty = it["qty"] as int;
                final hpp = it["hpp"] as double;
                final ecer = it["ecer"] as double;
                final agen = it["agen"] as double;
                // update HPP average & harga
                final b = await (db.select(db.barang)..where((t)=> t.id.equals(barangId))).getSingle();
                final totalStok = b.stok + qty;
                final newHpp = totalStok==0? hpp : ((b.hppAverage*b.stok + hpp*qty)/totalStok);
                await (db.update(db.barang)..where((t)=> t.id.equals(barangId))).write(BarangCompanion(stok: Value(totalStok), hppAverage: Value(newHpp), hargaEcer: Value(ecer==0? b.hargaEcer: ecer), hargaAgen: Value(agen==0? b.hargaAgen: agen)));
                await db.into(db.pembelian).insert(PembelianCompanion.insert(barangId: barangId, qtyPcs: qty, hargaBeliPerPcs: hpp, supplier: Value(supplierCtrl.text), noNota: Value(noNotaCtrl.text), tipeBayar: Value(tipeBayar)));
                await db.into(db.kartuStok).insert(KartuStokCompanion.insert(barangId: barangId, tipe: 'MASUK', qty: qty, stokAkhir: totalStok, hargaBeliSaatItu: Value(hpp), refId: Value(noNotaCtrl.text)));
              }
              // buat hutang jika TEMPO
              if(tipeBayar=="TEMPO" && items.isNotEmpty){
                final total = items.fold<double>(0,(s,it)=> s + (it["hpp"] as double)*(it["qty"] as int));
                await db.hutangDao.insertHutang(HutangSupplierCompanion.insert(
                  noNota: noNotaCtrl.text.isEmpty? "NOTA-${DateTime.now().millisecondsSinceEpoch}" : noNotaCtrl.text,
                  supplierNama: supplierCtrl.text.isEmpty? "Supplier" : supplierCtrl.text,
                  totalTagihan: total,
                  sisaHutang: total,
                  jatuhTempo: Value(DateTime.now().add(const Duration(days:30))),
                ));
              }
            });
            await inv.refreshAll();
            if(mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical:14)),
          child: const Text("Simpan Nota Masuk"),
        )),
      ])),
    );
  }
}
