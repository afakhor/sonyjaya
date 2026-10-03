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
  late TextEditingController skuC, namaC, merekC, satuanKecilC, satuanBesarC, konversiC, hppC, ecerC, agenC, stokC, safetyC;
  @override void initState() {
    super.initState();
    final b = widget.existing;
    skuC = TextEditingController(text: b?.sku?? '');
    namaC = TextEditingController(text: b?.nama?? '');
    merekC = TextEditingController(text: b?.merek?? '');
    satuanKecilC = TextEditingController(text: b?.satuanTerkecil?? 'Pcs');
    satuanBesarC = TextEditingController(text: b?.satuanBesar?? 'Set');
    konversiC = TextEditingController(text: (b?.konversi?? 1).toString());
    hppC = TextEditingController(text: (b?.hppAverage?? 0).toString());
    ecerC = TextEditingController(text: (b?.hargaEcer?? 0).toString());
    agenC = TextEditingController(text: (b?.hargaAgen?? 0).toString());
    stokC = TextEditingController(text: (b?.stok?? 0).toString());
    safetyC = TextEditingController(text: (b?.safetyStock?? 2).toString());
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null? 'Input Barang Perkakas Baru' : 'Edit Barang')),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: skuC, decoration: const InputDecoration(labelText: 'SKU / Kode', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: namaC, decoration: const InputDecoration(labelText: 'Nama Perkakas *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty? 'Wajib isi' : null),
        const SizedBox(height: 12),
        TextFormField(controller: merekC, decoration: const InputDecoration(labelText: 'Merek (Bosch, Makita, Tekiro)', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: TextFormField(controller: satuanKecilC, decoration: const InputDecoration(labelText: 'Satuan Kecil', border: OutlineInputBorder()))), const SizedBox(width: 12), Expanded(child: TextFormField(controller: satuanBesarC, decoration: const InputDecoration(labelText: 'Satuan Besar', border: OutlineInputBorder())))]),
        const SizedBox(height: 12),
        TextFormField(controller: konversiC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Konversi (isi per satuan besar)', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: stokC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Awal Pcs', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: safetyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Safety Stock', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: hppC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'HPP Average', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: ecerC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Ecer', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: agenC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Agen', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () async {
          if (!_formKey.currentState!.validate()) return;
          final db = ref.read(localDbProvider);
          final comp = BarangCompanion(sku: drift.Value(skuC.text.isEmpty? null : skuC.text), nama: drift.Value(namaC.text), merek: drift.Value(merekC.text.isEmpty? null : merekC.text), satuanTerkecil: drift.Value(satuanKecilC.text), satuanBesar: drift.Value(satuanBesarC.text), konversi: drift.Value(int.tryParse(konversiC.text)?? 1), stok: drift.Value(int.tryParse(stokC.text)?? 0), safetyStock: drift.Value(int.tryParse(safetyC.text)?? 2), hppAverage: drift.Value(double.tryParse(hppC.text)?? 0), hargaEcer: drift.Value(double.tryParse(ecerC.text)?? 0), hargaAgen: drift.Value(double.tryParse(agenC.text)?? 0), updatedAt: drift.Value(DateTime.now()));
          if (widget.existing == null) { await db.barangDao.insertBarang(comp); } else { await (db.update(db.barang)..where((b) => b.id.equals(widget.existing!.id))).write(comp); }
          if (context.mounted) Navigator.pop(context);
        }, child: Text(widget.existing == null? 'SIMPAN BARANG' : 'UPDATE BARANG'))
      ])),
    );
  }
}