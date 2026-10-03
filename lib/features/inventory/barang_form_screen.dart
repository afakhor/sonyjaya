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
  late TextEditingController skuC, namaC, merekC, satuanKecilC, satuanBesarC, konversiC, ecerC, agenC, stokC, safetyC;
  @override void initState() {
    super.initState();
    final b = widget.existing;
    skuC = TextEditingController(text: b?.sku ?? '');
    namaC = TextEditingController(text: b?.nama ?? '');
    merekC = TextEditingController(text: b?.merek ?? '');
    satuanKecilC = TextEditingController(text: b?.satuanTerkecil ?? 'Pcs');
    satuanBesarC = TextEditingController(text: b?.satuanBesar ?? 'Set');
    konversiC = TextEditingController(text: (b?.konversi ?? 1).toString());
    ecerC = TextEditingController(text: (b?.hargaEcer ?? 0).toString());
    agenC = TextEditingController(text: (b?.hargaAgen ?? 0).toString());
    stokC = TextEditingController(text: (b?.stok ?? 0).toString());
    safetyC = TextEditingController(text: (b?.safetyStock ?? 2).toString());
  }
  @override Widget build(BuildContext context) {
    final b = widget.existing;
    return Scaffold(
      appBar: AppBar(title: Text(b == null ? 'Input Barang Baru' : 'Edit Barang'), backgroundColor: Colors.white),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: skuC, decoration: const InputDecoration(labelText: 'SKU / Kode', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: namaC, decoration: const InputDecoration(labelText: 'Nama Perkakas *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Wajib' : null),
        const SizedBox(height: 12),
        TextFormField(controller: merekC, decoration: const InputDecoration(labelText: 'Merek (Bosch, Makita)', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: TextFormField(controller: satuanKecilC, decoration: const InputDecoration(labelText: 'Satuan Kecil', border: OutlineInputBorder()))), const SizedBox(width: 12), Expanded(child: TextFormField(controller: satuanBesarC, decoration: const InputDecoration(labelText: 'Satuan Besar', border: OutlineInputBorder())))]),
        const SizedBox(height: 12),
        TextFormField(controller: konversiC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Konversi isi per besar', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        if (b == null)
          TextFormField(controller: stokC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Awal Pcs (0 = nanti via Nota)', border: OutlineInputBorder()))
        else
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: Text('Stok saat ini: ${b.stok} Pcs (ubah via Nota Masuk / Opname)', style: const TextStyle(fontSize: 12))),
        const SizedBox(height: 12),
        TextFormField(controller: safetyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Safety Stock', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        if (b != null)
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('HPP AUTO (Moving Average) - LOCKED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
            Text('Rp ${b.hppAverage.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('Update: ${b.updatedAt.day}/${b.updatedAt.month}/${b.updatedAt.year} | Masuk Log Otomatis', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: () async {
              final ctrl = TextEditingController(text: b.hppAverage.toString());
              final newVal = await showDialog<double>(context: context, builder: (_) => AlertDialog(title: const Text('Koreksi HPP Tanpa Beli'), content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'HPP Baru')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(context, double.tryParse(ctrl.text)), child: const Text('Simpan'))]));
              if (newVal != null) {
                final db = ref.read(localDbProvider);
                await db.transaksiDao.koreksiHppTanpaBeli(barangId: b.id, hppBaru: newVal, keterangan: 'Koreksi manual');
                if (context.mounted) Navigator.pop(context);
              }
            }, icon: const Icon(Icons.edit_note_rounded, size: 18), label: const Text('Koreksi HPP Tanpa Beli (Pengaruh Average)')),
          ]))
        else
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: const Text('HPP akan auto kebuat saat Nota Masuk pertama dengan tanggal. Tidak perlu isi manual.', style: TextStyle(fontSize: 12))),
        const SizedBox(height: 12),
        TextFormField(controller: ecerC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Ecer', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: agenC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Agen', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () async {
          if (!_formKey.currentState!.validate()) return;
          final db = ref.read(localDbProvider);
          final comp = BarangCompanion(
            sku: drift.Value(skuC.text.isEmpty ? null : skuC.text), nama: drift.Value(namaC.text), merek: drift.Value(merekC.text.isEmpty ? null : merekC.text),
            satuanTerkecil: drift.Value(satuanKecilC.text), satuanBesar: drift.Value(satuanBesarC.text), konversi: drift.Value(int.tryParse(konversiC.text) ?? 1),
            stok: b == null ? drift.Value(int.tryParse(stokC.text) ?? 0) : const drift.Value.absent(),
            safetyStock: drift.Value(int.tryParse(safetyC.text) ?? 2),
            hppAverage: b == null ? const drift.Value(0) : const drift.Value.absent(),
            hargaEcer: drift.Value(double.tryParse(ecerC.text) ?? 0), hargaAgen: drift.Value(double.tryParse(agenC.text) ?? 0),
            updatedAt: drift.Value(DateTime.now()),
          );
          if (b == null) { await db.barangDao.insertBarang(comp); } else { await (db.update(db.barang)..where((t) => t.id.equals(b.id))).write(comp); }
          if (context.mounted) Navigator.pop(context);
        }, child: Text(b == null ? 'SIMPAN BARANG' : 'UPDATE BARANG'))
      ])),
    );
  }
}