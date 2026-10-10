// lib/features/inventory/barang_form_screen.dart - FIX FINAL KONVERSI SATUAN + UI CANTIK + TANPA DUMMY - BUILD LULUS
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
  late final namaCtrl = TextEditingController(text: widget.existing?.nama ?? "");
  late final skuCtrl = TextEditingController(text: widget.existing?.sku ?? "");
  late final merekCtrl = TextEditingController(text: widget.existing?.merek ?? "");
  late final stokCtrl = TextEditingController(text: "${widget.existing?.stok ?? 0}");
  late final hppCtrl = TextEditingController(text: "${widget.existing?.hppAverage ?? 0}");
  late final ecerCtrl = TextEditingController(text: "${widget.existing?.hargaEcer ?? 0}");
  late final agenCtrl = TextEditingController(text: "${widget.existing?.hargaAgen ?? 0}");
  late final satuanKecilCtrl = TextEditingController(text: widget.existing?.satuanTerkecil ?? "Pcs");
  late final satuanBesarCtrl = TextEditingController(text: widget.existing?.satuanBesar ?? "Dus");
  late final konversiCtrl = TextEditingController(text: "${widget.existing?.konversi ?? 1}");

  List<Map<String,TextEditingController>> variasis = [];

  @override void initState(){
    super.initState();
    _addVariasi();
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
        "satuanKecil": TextEditingController(text:"Pcs"),
        "satuanBesar": TextEditingController(text:"Dus"),
        "konversi": TextEditingController(text:"1"),
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
      appBar: AppBar(title: Text(widget.existing==null? "Input Barang Baru" : "Edit Barang"), backgroundColor: Colors.white, elevation:0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Data Barang Utama
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Data Barang Utama", style: TextStyle(fontWeight: FontWeight.bold, fontSize:15)),
            const SizedBox(height:12),
            TextField(controller: namaCtrl, decoration: _dec("Nama Barang")),
            const SizedBox(height:10),
            Row(children: [
              Expanded(child: TextField(controller: skuCtrl, decoration: _dec("SKU"))),
              const SizedBox(width:8),
              Expanded(child: TextField(controller: merekCtrl, decoration: _dec("Merek"))),
            ]),
            const SizedBox(height:12),
            // === KONVERSI SATUAN UNIT - YANG HILANG - BALIKIN LAGI - GARIS BIRU ===
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [Icon(Icons.swap_horiz, size:16, color: Color(0xFF2563EB)), SizedBox(width:6), Text("Konversi Satuan Unit", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Color(0xFF2563EB)))]),
                const SizedBox(height:8),
                Row(children: [
                  Expanded(child: TextField(controller: satuanKecilCtrl, decoration: _decSmall("Satuan Kecil").copyWith(hintText:"Pcs"))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal:6), child: Text("=", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: TextField(controller: konversiCtrl, keyboardType: TextInputType.number, decoration: _decSmall("Isi"))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal:6), child: Text("x", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: TextField(controller: satuanBesarCtrl, decoration: _decSmall("Satuan Besar").copyWith(hintText:"Dus"))),
                ]),
                const SizedBox(height:6),
                ValueListenableBuilder<TextEditingValue>(valueListenable: konversiCtrl, builder: (ctx,val,__){
                  return Text("Contoh: 1 ${satuanBesarCtrl.text.isEmpty? "Dus" : satuanBesarCtrl.text} = ${konversiCtrl.text.isEmpty? "1" : konversiCtrl.text} ${satuanKecilCtrl.text.isEmpty? "Pcs" : satuanKecilCtrl.text}", style: const TextStyle(fontSize:10,color: Colors.black54));
                }),
              ]),
            ),
            const SizedBox(height:10),
            Row(children: [
              Expanded(child: TextField(controller: stokCtrl, keyboardType: TextInputType.number, decoration: _dec("Stok (${satuanKecilCtrl.text})"))),
              const SizedBox(width:8),
              Expanded(child: TextField(controller: hppCtrl, keyboardType: TextInputType.number, decoration: _dec("HPP / Harga Beli"))),
            ]),
            const SizedBox(height:10),
            Row(children: [
              Expanded(child: TextField(controller: ecerCtrl, keyboardType: TextInputType.number, decoration: _dec("Harga Ecer"))),
              const SizedBox(width:8),
              Expanded(child: TextField(controller: agenCtrl, keyboardType: TextInputType.number, decoration: _dec("Harga Agen"))),
            ]),
          ]),
        ),
        const SizedBox(height:16),
        // Variasi
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Input Variasi + Harga (${variasis.length} SKU)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:14)),
              // UI cantik: cukup tombol tambah kecil hitam, bukan full lebar
              InkWell(
                onTap: _addVariasi,
                child: Container(padding: const EdgeInsets.symmetric(horizontal:12,vertical:6), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: const Text("+ Tambah", style: TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.bold))),
              ),
            ]),
            const SizedBox(height:12),
            ...List.generate(variasis.length, (i){
              final v = variasis[i];
              return Container(
                margin: const EdgeInsets.only(bottom:12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(16), color: const Color(0xFFFAFAFA)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: Text("Variasi #${i+1}", style: const TextStyle(color: Colors.white, fontSize:11, fontWeight: FontWeight.bold))),
                    InkWell(onTap: ()=> setState(()=> variasis.removeAt(i)), child: const Text("Hapus", style: TextStyle(color: Colors.red, fontSize:12, fontWeight: FontWeight.bold))),
                  ]),
                  const SizedBox(height:10),
                  TextField(controller: v["nama"]!, decoration: _dec("Nama Variasi")),
                  const SizedBox(height:8),
                  Row(children: [
                    Expanded(child: TextField(controller: v["sku"]!, decoration: _dec("SKU Variasi"))),
                    const SizedBox(width:8),
                    // Stok + satuan - garis biru
                    Expanded(child: TextField(controller: v["stok"]!, keyboardType: TextInputType.number, decoration: _dec("Stok (${v["satuanKecil"]!.text})"))),
                  ]),
                  const SizedBox(height:8),
                  // Konversi di variasi juga
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
                    child: Row(children: [
                      Expanded(child: TextField(controller: v["satuanKecil"]!, decoration: _decSmall("Kecil"))),
                      const SizedBox(width:6),
                      Expanded(child: TextField(controller: v["konversi"]!, keyboardType: TextInputType.number, decoration: _decSmall("Konv"))),
                      const SizedBox(width:6),
                      Expanded(child: TextField(controller: v["satuanBesar"]!, decoration: _decSmall("Besar"))),
                    ]),
                  ),
                  const SizedBox(height:8),
                  TextField(controller: v["hpp"]!, keyboardType: TextInputType.number, decoration: _dec("HPP / Harga Beli")),
                  const SizedBox(height:8),
                  Row(children: [
                    Expanded(child: _priceBox("Harga Ecer", v["ecer"]!, v["hpp"]!, const Color(0xFFFFF7ED))),
                    const SizedBox(width:6),
                    Expanded(child: _priceBox("Harga Agen", v["agen"]!, v["hpp"]!, const Color(0xFFEFF6FF))),
                    const SizedBox(width:6),
                    Expanded(child: _priceBox("Manual", v["manual"]!, v["hpp"]!, const Color(0xFFF9FAFB))),
                  ]),
                ]),
              );
            }),
          ]),
        ),
        const SizedBox(height:20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _simpan, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical:14)), child: const Text("Simpan Barang"))),
        const SizedBox(height:80),
      ])),
    );
  }

  InputDecoration _dec(String label)=> InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense:true, contentPadding: const EdgeInsets.symmetric(horizontal:12,vertical:12));
  InputDecoration _decSmall(String label)=> InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense:true, contentPadding: const EdgeInsets.symmetric(horizontal:10,vertical:10), labelStyle: const TextStyle(fontSize:11));

  Widget _priceBox(String label, TextEditingController ctrl, TextEditingController hppCtrl, Color bg){
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
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
    if(widget.existing==null){
      final barangId = await db.barangDao.insertBarang(BarangCompanion.insert(
        sku: skuCtrl.text.isEmpty? "SKU-${DateTime.now().millisecondsSinceEpoch}" : skuCtrl.text,
        nama: namaCtrl.text,
        merek: drift.Value(merekCtrl.text),
        stok: drift.Value(int.tryParse(stokCtrl.text)??0),
        hppAverage: drift.Value(double.tryParse(hppCtrl.text)??0),
        hargaEcer: drift.Value(double.tryParse(ecerCtrl.text)??0),
        hargaAgen: drift.Value(double.tryParse(agenCtrl.text)??0),
        satuanTerkecil: drift.Value(satuanKecilCtrl.text.isEmpty? "Pcs" : satuanKecilCtrl.text),
        satuanBesar: drift.Value(satuanBesarCtrl.text.isEmpty? "Dus" : satuanBesarCtrl.text),
        konversi: drift.Value(int.tryParse(konversiCtrl.text)??1),
        satuan: drift.Value(satuanKecilCtrl.text.isEmpty? "Pcs" : satuanKecilCtrl.text),
      ));
      for(var v in variasis){
        if(v["nama"]!.text.isEmpty) continue;
        await db.barangDao.insertVariasi(BarangVariasiCompanion.insert(
          barangId: barangId,
          variasiNama: v["nama"]!.text,
          skuVariasi: drift.Value(v["sku"]!.text),
          stok: drift.Value(int.tryParse(v["stok"]!.text)??0),
          hargaEcer: drift.Value(double.tryParse(v["ecer"]!.text)),
          hargaAgen: drift.Value(double.tryParse(v["agen"]!.text)),
          keterangan: drift.Value("Manual:${v["manual"]!.text}|Konv:${v["konversi"]!.text} ${v["satuanKecil"]!.text}=1 ${v["satuanBesar"]!.text}"),
        ));
      }
    } else {
      await db.barangDao.updateBarang(widget.existing!.copyWith(
        nama: namaCtrl.text, sku: skuCtrl.text, merek: drift.Value(merekCtrl.text),
        stok: int.tryParse(stokCtrl.text)??0,
        hppAverage: double.tryParse(hppCtrl.text)??0,
        hargaEcer: double.tryParse(ecerCtrl.text)??0,
        hargaAgen: double.tryParse(agenCtrl.text)??0,
        satuanTerkecil: drift.Value(satuanKecilCtrl.text),
        satuanBesar: drift.Value(satuanBesarCtrl.text),
        konversi: int.tryParse(konversiCtrl.text)??1,
        satuan: drift.Value(satuanKecilCtrl.text),
      ));
    }
    ref.invalidate(barangListProvider);
    if(mounted) Navigator.pop(context);
  }
}
