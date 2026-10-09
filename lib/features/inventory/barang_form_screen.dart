// lib/features/inventory/barang_form_screen.dart - FINAL BUILD FIX - updatedAt ada, localDbProvider ada
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangFormScreen extends ConsumerStatefulWidget {
  final BarangData? existing;
  const BarangFormScreen({super.key, this.existing});
  @override ConsumerState<BarangFormScreen> createState() => _BarangFormScreenState();
}
class _BarangFormScreenState extends ConsumerState<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController skuC,namaC,merekC,kecilC,besarC,konvC,ecerC,agenC,safetyC,supplierC;
  SupplierData? _selectedSupplier;
  List<Map<String,TextEditingController>> _variasi=[];
  List<BarangVariasiData> _existingVariasi=[];
  @override void initState(){
    super.initState();
    final b=widget.existing;
    skuC=TextEditingController(text:b?.sku??''); namaC=TextEditingController(text:b?.nama??''); merekC=TextEditingController(text:b?.merek??''); supplierC=TextEditingController(text:b?.supplierNama??'');
    kecilC=TextEditingController(text:b?.satuanTerkecil??'Pcs'); besarC=TextEditingController(text:b?.satuanBesar??'Set'); konvC=TextEditingController(text:(b?.konversi??1).toString());
    ecerC=TextEditingController(text:(b?.hargaEcer??0).toStringAsFixed(0)); agenC=TextEditingController(text:(b?.hargaAgen??0).toStringAsFixed(0)); safetyC=TextEditingController(text:(b?.safetyStock??2).toString());
    skuC.addListener(_autoFillBiru);
    if(b!=null) _loadVariasi(b.id);
  }
  Future<void> _loadVariasi(int id) async { final db=ref.read(localDbProvider); final list=await db.barangDao.getVariasi(id); setState(()=>_existingVariasi=list); }
  Future<void> _autoFillBiru() async {
    if(widget.existing!=null) return;
    final sku=skuC.text.trim(); if(sku.length<3) return;
    final db=ref.read(localDbProvider); final ex=await db.barangDao.getBySku(sku);
    if(ex!=null && mounted){ setState((){ namaC.text=ex.nama; merekC.text=ex.merek??''; supplierC.text=ex.supplierNama??''; kecilC.text=ex.satuanTerkecil; besarC.text=ex.satuanBesar; konvC.text=ex.konversi.toString(); }); }
  }
  void _addVariasi(){ setState(()=>_variasi.add({'nama':TextEditingController(),'sku':TextEditingController(),'stok':TextEditingController(text:'0')})); }
  double margin(double jual,double hpp)=>hpp==0?0:(jual-hpp)/hpp*100;
  @override void dispose(){ skuC.removeListener(_autoFillBiru); skuC.dispose(); namaC.dispose(); merekC.dispose(); supplierC.dispose(); kecilC.dispose(); besarC.dispose(); konvC.dispose(); ecerC.dispose(); agenC.dispose(); safetyC.dispose(); for(var v in _variasi){ v['nama']!.dispose(); v['sku']!.dispose(); v['stok']!.dispose(); } super.dispose(); }
  @override Widget build(BuildContext context){
    final b=widget.existing; final hpp=b?.hppAverage??0;
    return Scaffold(appBar: AppBar(title: Text(b==null?'Input Barang Baru':'Edit Barang'), backgroundColor: Colors.white, elevation:0, surfaceTintColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=>Navigator.pop(context))), backgroundColor: const Color(0xFFF8FAFC),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: skuC, decoration: const InputDecoration(labelText: 'SKU / Kode', border: OutlineInputBorder())),
        const SizedBox(height:12),
        TextFormField(controller: namaC, decoration: const InputDecoration(labelText: 'Nama Perkakas *', border: OutlineInputBorder()), validator: (v)=>v!.isEmpty?'Wajib':null),
        const SizedBox(height:12),
        TextFormField(controller: merekC, decoration: const InputDecoration(labelText: 'Merek (Bosch, Makita)', border: OutlineInputBorder())),
        const SizedBox(height:12),
        Autocomplete<SupplierData>(
          displayStringForOption: (s)=>s.nama,
          optionsBuilder: (v) async { final all=await ref.read(localDbProvider).supplierDao.getAll(); if(v.text.isEmpty) return all; return all.where((e)=>e.nama.toLowerCase().contains(v.text.toLowerCase())); },
          onSelected: (s)=>setState((){_selectedSupplier=s; supplierC.text=s.nama;}),
          fieldViewBuilder: (c,ctrl,f,_){ if(supplierC.text.isNotEmpty && ctrl.text.isEmpty) ctrl.text=supplierC.text; return TextField(controller: ctrl, focusNode: f, decoration: const InputDecoration(labelText: 'Supplier - auto nyambung', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_shipping)), onChanged: (v)=>supplierC.text=v); },
        ),
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
        const SizedBox(height:20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(b==null?'Variasi Unlimited (1 SKU bisa banyak)':'Variasi (${_existingVariasi.length})', style: const TextStyle(fontWeight: FontWeight.bold)), TextButton.icon(onPressed: _addVariasi, icon: const Icon(Icons.add), label: const Text('Tambah Variasi'))]),
        if(_existingVariasi.isNotEmpty) ..._existingVariasi.map((v)=> Container(margin: const EdgeInsets.only(bottom:8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)), child: Row(children: [Expanded(child: Text('${v.variasiNama} • SKU: ${v.skuVariasi??'-'} • Stok ${v.stok}')), IconButton(icon: const Icon(Icons.delete_outline, size:18), onPressed: () async { final db=ref.read(localDbProvider); await (db.delete(db.barangVariasi)..where((t)=>t.id.equals(v.id))).go(); _loadVariasi(b!.id); })]))),
        ..._variasi.asMap().entries.map((e){ final idx=e.key; final v=e.value; return Container(margin: const EdgeInsets.only(bottom:10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12), color: Colors.white), child: Column(children: [Row(children: [Text('Variasi Baru #${idx+1}', style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: ()=>setState(()=>_variasi.removeAt(idx)))]), TextField(controller: v['nama'], decoration: const InputDecoration(labelText: 'Nama Variasi (Merah, 10mm)', border: OutlineInputBorder(), isDense:true)), const SizedBox(height:8), Row(children: [Expanded(child: TextField(controller: v['sku'], decoration: const InputDecoration(labelText: 'SKU Variasi opsional', border: OutlineInputBorder(), isDense:true))), const SizedBox(width:8), SizedBox(width:80, child: TextField(controller: v['stok'], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder(), isDense:true)))])])); }),
        const SizedBox(height:24),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical:14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () async {
          if(!_formKey.currentState!.validate()) return; final db=ref.read(localDbProvider);
          final comp=BarangCompanion(sku: drift.Value(skuC.text.isEmpty?null:skuC.text.trim()), nama: drift.Value(namaC.text.trim()), merek: drift.Value(merekC.text.isEmpty?null:merekC.text.trim()), supplierNama: drift.Value(supplierC.text.isEmpty?null:supplierC.text.trim()), supplierId: drift.Value(_selectedSupplier?.id), satuanTerkecil: drift.Value(kecilC.text), satuanBesar: drift.Value(besarC.text), konversi: drift.Value(int.tryParse(konvC.text)??1), stok: b==null? const drift.Value(0): const drift.Value.absent(), safetyStock: drift.Value(int.tryParse(safetyC.text)??2), hppAverage: b==null? const drift.Value(0): const drift.Value.absent(), hargaEcer: drift.Value(double.tryParse(ecerC.text)??0), hargaAgen: drift.Value(double.tryParse(agenC.text)??0), updatedAt: drift.Value(DateTime.now()));
          int barangId; if(b==null){ barangId=await db.barangDao.insertBarang(comp); } else { await (db.update(db.barang)..where((t)=>t.id.equals(b.id))).write(comp); barangId=b.id; }
          for(var v in _variasi){ if(v['nama']!.text.trim().isEmpty) continue; await db.barangDao.insertVariasi(BarangVariasiCompanion.insert(barangId: barangId, variasiNama: v['nama']!.text.trim(), skuVariasi: drift.Value(v['sku']!.text.trim().isEmpty?null:v['sku']!.text.trim()), stok: drift.Value(int.tryParse(v['stok']!.text)??0))); }
          if(context.mounted) Navigator.pop(context);
        }, child: Text(b==null?'SIMPAN BARANG':'UPDATE BARANG'))
      ])),
    );
  }
}
