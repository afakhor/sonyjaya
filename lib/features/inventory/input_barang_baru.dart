import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/local_database.dart';
import 'providers/supplier_provider_v8.dart';

class InputBarangBaruScreen extends ConsumerStatefulWidget {
  const InputBarangBaruScreen({super.key});
  @override ConsumerState<InputBarangBaruScreen> createState() => _InputBarangBaruScreenState();
}

class _InputBarangBaruScreenState extends ConsumerState<InputBarangBaruScreen> {
  final skuCtrl = TextEditingController();
  final namaCtrl = TextEditingController();
  final merekCtrl = TextEditingController();
  final satuanKecilCtrl = TextEditingController(text: 'Pcs');
  final satuanBesarCtrl = TextEditingController(text: 'Set');
  final konversiCtrl = TextEditingController(text: '1');
  final safetyCtrl = TextEditingController(text: '2');
  final ecerCtrl = TextEditingController(text: '0');
  final agenCtrl = TextEditingController(text: '0');

  // Variasi unlimited
  List<Map<String, TextEditingController>> variasiList = [];

  void _addVariasi() {
    setState(() {
      variasiList.add({
        'nama': TextEditingController(),
        'sku': TextEditingController(),
        'stok': TextEditingController(text: '0'),
      });
    });
  }

  // Auto nyambung biru: ketik SKU -> auto isi nama, merek, supplier
  Future<void> _onSkuChanged(String sku) async {
    if (sku.isEmpty) return;
    final db = ref.read(localDbProvider);
    final existing = await db.barangDao.getBySku(sku);
    if (existing != null) {
      setState(() {
        namaCtrl.text = existing.nama;
        merekCtrl.text = existing.merek ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SKU $sku sudah ada - auto isi: ${existing.nama}')));
    }
  }

  Future<void> _simpan() async {
    if (skuCtrl.text.isEmpty || namaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SKU dan Nama wajib')));
      return;
    }
    final db = ref.read(localDbProvider);
    final barangId = await db.barangDao.insertBarang(BarangCompanion.insert(
      sku: skuCtrl.text.trim(),
      nama: namaCtrl.text.trim(),
      merek: drift.Value(merekCtrl.text.trim()),
      supplierNama: drift.Value(''), // nanti diisi dari supplier dropdown
      satuan: drift.Value(satuanKecilCtrl.text),
      hargaEcer: drift.Value(double.tryParse(ecerCtrl.text) ?? 0),
      hargaAgen: drift.Value(double.tryParse(agenCtrl.text) ?? 0),
    ));

    // Simpan variasi unlimited
    for (var v in variasiList) {
      if (v['nama']!.text.isNotEmpty) {
        await db.barangDao.insertVariasi(BarangVariasiCompanion.insert(
          barangId: barangId,
          variasiNama: v['nama']!.text.trim(),
          skuVariasi: drift.Value(v['sku']!.text.trim().isEmpty ? null : v['sku']!.text.trim()),
          stok: drift.Value(int.tryParse(v['stok']!.text) ?? 0),
        ));
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Barang ${namaCtrl.text} + ${variasiList.length} variasi disimpan')));
      Navigator.pop(context);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Input Barang Baru'), backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: skuCtrl, onChanged: _onSkuChanged, decoration: const InputDecoration(labelText: 'SKU / Kode *', border: OutlineInputBorder())), // BIRU
          const SizedBox(height: 12),
          TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Perkakas *', border: OutlineInputBorder())), // BIRU - auto nyambung
          const SizedBox(height: 12),
          TextField(controller: merekCtrl, decoration: const InputDecoration(labelText: 'Merek (Bosch, Makita)', border: OutlineInputBorder())), // BIRU
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: satuanKecilCtrl, decoration: const InputDecoration(labelText: 'Satuan Kecil', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: satuanBesarCtrl, decoration: const InputDecoration(labelText: 'Satuan Besar', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: konversiCtrl, decoration: const InputDecoration(labelText: 'Konversi isi per besar', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)), child: const Text('Stok Awal = 0 (auto via Nota Masuk) - input ungu dibuang', style: TextStyle(fontSize: 12))),
          const SizedBox(height: 12),
          TextField(controller: safetyCtrl, decoration: const InputDecoration(labelText: 'Safety Stock', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: ecerCtrl, decoration: const InputDecoration(labelText: 'Harga Ecer', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: agenCtrl, decoration: const InputDecoration(labelText: 'Harga Agen', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          // VARIASI UNLIMITED
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Variasi (Unlimited)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(onPressed: _addVariasi, icon: const Icon(Icons.add), label: const Text('Tambah Variasi')),
          ]),
          ...variasiList.asMap().entries.map((entry) {
            final idx = entry.key;
            final v = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Row(children: [Text('Variasi #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => variasiList.removeAt(idx)))]),
                TextField(controller: v['nama'], decoration: const InputDecoration(labelText: 'Nama Variasi (mis: Merah, 10mm)', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: v['sku'], decoration: const InputDecoration(labelText: 'SKU Variasi (opsional)', border: OutlineInputBorder(), isDense: true))),
                  const SizedBox(width: 8),
                  SizedBox(width: 80, child: TextField(controller: v['stok'], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder(), isDense: true))),
                ]),
              ]),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))), onPressed: _simpan, child: const Text('SIMPAN BARANG + VARIASI', style: TextStyle(fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }
}
