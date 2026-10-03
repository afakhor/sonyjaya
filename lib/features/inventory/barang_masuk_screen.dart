import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangMasukScreen extends ConsumerStatefulWidget {
  const BarangMasukScreen({super.key});
  @override ConsumerState<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends ConsumerState<BarangMasukScreen> {
  final _searchC=TextEditingController();
  BarangData? _selected;
  final _qtyC=TextEditingController();
  final _hargaC=TextEditingController();
  final _hppSementaraC=TextEditingController();
  final _supplierC=TextEditingController();
  final _notaC=TextEditingController(text:'NOTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
  DateTime _tanggal=DateTime.now();
  bool _isBesar=false;
  bool _isKoreksi=false;

  Future<void> _pickTgl() async { final p=await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime(2030)); if(p!=null) setState(()=>_tanggal=p); }

  Future<void> _proses({bool next=false}) async {
    final db=ref.read(localDbProvider); final ctrl=ref.read(inventoryControllerProvider);
    if(_selected==null){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih barang'))); return; }
    try{
      if(_isKoreksi){
        final hppBaru=double.tryParse(_hppSementaraC.text)??0; if(hppBaru<=0) throw Exception('HPP sementara wajib >0');
        await db.transaksiDao.koreksiHppTanpaBeli(barangId: _selected!.id, hppBaru: hppBaru, keterangan: 'KOREKSI_HPP Pasar ${_notaC.text} Tgl ${_tanggal.day}/${_tanggal.month}', tanggal: _tanggal);
      } else {
        final qty=int.tryParse(_qtyC.text)??0; final harga=double.tryParse(_hargaC.text)??0; if(qty<=0||harga<=0) throw Exception('Qty & Harga wajib');
        await ctrl.beli(barangId: _selected!.id, qty: qty, harga: harga, isSatuanBesar: _isBesar, supplier: _supplierC.text, tanggal: _tanggal, nota: _notaC.text);
      }
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isKoreksi? 'HPP Sementara Rp ${_hppSementaraC.text} tgl ${_tanggal.day}/${_tanggal.month} masuk LOG':'Nota ${_notaC.text} HPP auto')));
      if(!next) Navigator.pop(context); else setState((){ _qtyC.clear(); _hargaC.clear(); _hppSementaraC.clear(); _notaC.text='NOTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'; });
    }catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'))); }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Nota Masuk + HPP Auto + Log'), backgroundColor: Colors.white), backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [Expanded(child: InkWell(onTap: _pickTgl, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [const Icon(Icons.calendar_month_rounded, size:18), const SizedBox(width:8), Text('${_tanggal.day}/${_tanggal.month}/${_tanggal.year}', style: const TextStyle(fontWeight: FontWeight.bold))])))), const SizedBox(width:10), Expanded(child: TextField(controller: _notaC, decoration: const InputDecoration(labelText: 'No Nota', border: OutlineInputBorder(), isDense:true)))]),
        const SizedBox(height:16),
        Autocomplete<BarangData>(displayStringForOption: (b)=>b.nama, optionsBuilder: (v) async { if(v.text.isEmpty) return const Iterable<BarangData>.empty(); return await ref.read(localDbProvider).barangDao.cariBarang(v.text); }, onSelected: (s)=>setState((){_selected=s; _searchC.text=s.nama;}), fieldViewBuilder: (c,ctrl,f,_)=> TextField(controller: ctrl, focusNode: f, decoration: InputDecoration(labelText: 'Cari Barang auto suggest', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: (){ctrl.clear(); setState(()=>_selected=null);})), onChanged: (v)=>_searchC.text=v), optionsViewBuilder: (c,onSel,opts)=>Align(alignment: Alignment.topLeft, child: Material(elevation: 4, child: SizedBox(width: MediaQuery.of(c).size.width-32, child: ListView.builder(shrinkWrap: true, itemCount: opts.length, itemBuilder: (_,i){ final b=opts.elementAt(i); return ListTile(title: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Stok: ${b.stok} | HPP: Rp ${b.hppAverage.toStringAsFixed(0)}'), onTap: ()=>onSel(b)); })))),
        const SizedBox(height:16),
        if(_selected!=null) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_selected!.nama, style: const TextStyle(fontWeight: FontWeight.bold)), Text('Stok: ${_selected!.stok} | HPP Saat Ini: Rp ${_selected!.hppAverage.toStringAsFixed(0)} | ${_selected!.satuanTerkecil}/${_selected!.satuanBesar} isi ${_selected!.konversi}', style: const TextStyle(fontSize:11)), Text('Ecer Rp ${_selected!.hargaEcer.toStringAsFixed(0)} (${_selected!.hppAverage==0?0: ((_selected!.hargaEcer-_selected!.hppAverage)/_selected!.hppAverage*100).toStringAsFixed(0)}%) | Agen Rp ${_selected!.hargaAgen.toStringAsFixed(0)} (${_selected!.hppAverage==0?0: ((_selected!.hargaAgen-_selected!.hppAverage)/_selected!.hppAverage*100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize:11, fontWeight: FontWeight.w600))])),
        const SizedBox(height:12),
        Row(children: [Checkbox(value: _isKoreksi, onChanged: (v)=>setState(()=>_isKoreksi=v??false)), const Expanded(child: Text('Koreksi HPP Sementara (perubahan harga belum repeat beli) + Tgl + Log', style: TextStyle(fontSize:12, fontWeight: FontWeight.bold)))]),
        if(_isKoreksi)...[
          TextField(controller: _hppSementaraC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Input HPP Sementara Baru * Tgl ${_tanggal.day}/${_tanggal.month}/${_tanggal.year}', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.price_change_rounded))),
        ] else...[
          TextField(controller: _qtyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty Masuk *', border: OutlineInputBorder()), onChanged: (_)=>setState((){})),
          const SizedBox(height:12),
          TextField(controller: _hargaC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Beli per ${_isBesar?"Besar":"Pcs"} *', border: const OutlineInputBorder()), onChanged: (_)=>setState((){})),
          const SizedBox(height:8),
          if(_selected!=null && _qtyC.text.isNotEmpty && _hargaC.text.isNotEmpty) Builder(builder: (_){ final oldS=_selected!.stok; final oldH=_selected!.hppAverage; final q=int.tryParse(_qtyC.text)??0; final h=double.tryParse(_hargaC.text)??0; if(q==0||h==0) return const SizedBox.shrink(); final newH= oldS<=0? h : ((oldS*oldH)+(q*h))/(oldS+q); return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HPP Baru Auto: Rp ${newH.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:12)), Text('Rumus: ($oldS x ${oldH.toStringAsFixed(0)} + $q x $h) / ${oldS+q}', style: const TextStyle(fontSize:11))])); }),
        ],
        const SizedBox(height:12),
        Autocomplete<String>(optionsBuilder: (v) async { final all=await (ref.read(localDbProvider).select(ref.read(localDbProvider).supplier)).get(); return all.map((e)=>e.nama).where((s)=>s.toLowerCase().contains(v.text.toLowerCase())); }, fieldViewBuilder: (c,ctrl,f,_)=> TextField(controller: ctrl, focusNode: f, decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()), onChanged: (v)=>_supplierC.text=v), onSelected: (s)=>_supplierC.text=s),
        if(!_isKoreksi) Row(children: [Checkbox(value: _isBesar, onChanged: (v)=>setState(()=>_isBesar=v??false)), Text(_isBesar? 'Satuan Besar x${_selected?.konversi??1}' : 'Satuan Kecil Pcs')]),
        const SizedBox(height:20),
        Row(children: [Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical:16)), onPressed: ()=>_proses(next:false), icon: const Icon(Icons.save), label: Text(_isKoreksi? 'SIMPAN KOREKSI HPP + LOG' : 'SIMPAN & TUTUP'))), const SizedBox(width:10), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), side: const BorderSide(color: Color(0xFF0F172A))), onPressed: ()=>_proses(next:true), icon: const Icon(Icons.skip_next_rounded), label: const Text('SIMPAN & NEXT')))]),
      ])),
    );
  }
}