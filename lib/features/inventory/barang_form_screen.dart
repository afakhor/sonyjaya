import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangFormScreen extends ConsumerStatefulWidget {
  final BarangData? existing;
  const BarangFormScreen({super.key, this.existing});
  @override ConsumerState<BarangFormScreen> createState() => _BarangFormScreenState();
}
class _BarangFormScreenState extends ConsumerState<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController skuC,namaC,merekC,kecilC,besarC,konvC,ecerC,agenC,safetyC;
  @override void initState() { super.initState(); final b=widget.existing; skuC=TextEditingController(text:b?.sku??''); namaC=TextEditingController(text:b?.nama??''); merekC=TextEditingController(text:b?.merek??''); kecilC=TextEditingController(text:b?.satuanTerkecil??'Pcs'); besarC=TextEditingController(text:b?.satuanBesar??'Set'); konvC=TextEditingController(text:(b?.konversi??1).toString()); ecerC=TextEditingController(text:(b?.hargaEcer??0).toStringAsFixed(0)); agenC=TextEditingController(text:(b?.hargaAgen??0).toStringAsFixed(0)); safetyC=TextEditingController(text:(b?.safetyStock??2).toString()); }
  double margin(double jual,double hpp)=>hpp==0?0:(jual-hpp)/hpp*100;
  @override Widget build(BuildContext context) {
    final b=widget.existing; final hpp=b?.hppAverage??0;
    return Scaffold(appBar: AppBar(title: Text(b==null?'Input Barang Baru':'Edit Barang'), backgroundColor: Colors.white), backgroundColor: const Color(0xFFF8FAFC),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: skuC, decoration: const InputDecoration(labelText: 'SKU / Kode', border: OutlineInputBorder())),
        const SizedBox(height:12),
        TextFormField(controller: namaC, decoration: const InputDecoration(labelText: 'Nama Perkakas *', border: OutlineInputBorder()), validator: (v)=>v!.isEmpty?'Wajib':null),
        const SizedBox(height:12),
        TextFormField(controller: merekC, decoration: const InputDecoration(labelText: 'Merek (Bosch, Makita)', border: OutlineInputBorder())),
        const SizedBox(height:12),
        Row(children: [Expanded(child: TextFormField(controller: kecilC, decoration: const InputDecoration(labelText: 'Satuan Kecil', border: OutlineInputBorder()))), const SizedBox(width:12), Expanded(child: TextFormField(controller: besarC, decoration: const InputDecoration(labelText: 'Satuan Besar', border: OutlineInputBorder())))]),
        const SizedBox(height:12),
        TextFormField(controller: konvC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Konversi isi per besar', border: OutlineInputBorder())),
        const SizedBox(height:12),
        if(b==null) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)), child: const Text('Stok Awal = 0 (auto via Nota Masuk) - input ungu dibuang', style: TextStyle(fontSize:12)))
        else Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: Text('Stok saat ini: ${b.stok} Pcs | HPP: Rp ${b.hppAverage.toStringAsFixed(0)} (ubah via Nota Masuk)', style: const TextStyle(fontSize:12))),
        const SizedBox(height:12),
        TextFormField(controller: safetyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Safety Stock', border: OutlineInputBorder())),
        const SizedBox(height:12),
        if(b!=null) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('HPP AUTO (Moving Average) - LOCKED', style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.green)), Text('Rp ${b.hppAverage.toStringAsFixed(0)}', style: const TextStyle(fontSize:22, fontWeight: FontWeight.w800)), Text('Update: ${b.updatedAt.day}/${b.updatedAt.month}/${b.updatedAt.year} | Log CCTV', style: const TextStyle(fontSize:11, color: Colors.grey))])),
        const SizedBox(height:12),
        TextFormField(controller: ecerC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Ecer ${ecerC.text.isNotEmpty?"(${margin(double.tryParse(ecerC.text)??0,hpp).toStringAsFixed(0)}% dari HPP)":""}', border: const OutlineInputBorder()), onChanged: (_)=>setState((){})),
        const SizedBox(height:12),
        TextFormField(controller: agenC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Agen ${agenC.text.isNotEmpty?"(${margin(double.tryParse(agenC.text)??0,hpp).toStringAsFixed(0)}% dari HPP)":""}', border: const OutlineInputBorder()), onChanged: (_)=>setState((){})),
        const SizedBox(height:24),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical:14)), onPressed: () async {
          if(!_formKey.currentState!.validate()) return; final db=ref.read(localDbProvider);
          final comp=BarangCompanion(sku: drift.Value(skuC.text.isEmpty?null:skuC.text), nama: drift.Value(namaC.text), merek: drift.Value(merekC.text.isEmpty?null:merekC.text), satuanTerkecil: drift.Value(kecilC.text), satuanBesar: drift.Value(besarC.text), konversi: drift.Value(int.tryParse(konvC.text)??1), stok: b==null? const drift.Value(0): const drift.Value.absent(), safetyStock: drift.Value(int.tryParse(safetyC.text)??2), hppAverage: b==null? const drift.Value(0): const drift.Value.absent(), hargaEcer: drift.Value(double.tryParse(ecerC.text)??0), hargaAgen: drift.Value(double.tryParse(agenC.text)??0), updatedAt: drift.Value(DateTime.now()));
          if(b==null) await db.barangDao.insertBarang(comp); else await (db.update(db.barang)..where((t)=>t.id.equals(b.id))).write(comp);
          if(context.mounted) Navigator.pop(context);
        }, child: Text(b==null?'SIMPAN BARANG':'UPDATE BARANG'))
      ])),
    );
  }
}