// lib/features/inventory/barang_masuk_screen.dart - KODE LENGKAP FIX - TETAP CLASS BarangMasukScreen
// LOGIKA LAMA DIPERTAHANKAN + TAMBAHAN BIRU KUNING + HUTANG SYNC + VARIASI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangMasukScreen extends ConsumerStatefulWidget {
  const BarangMasukScreen({super.key});
  @override ConsumerState<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends ConsumerState<BarangMasukScreen> {
  final TextEditingController _searchC = TextEditingController();
  BarangData? _selected;
  BarangVariasiData? _selectedVariasi;
  List<BarangVariasiData> _variasiList = [];
  final TextEditingController _qtyC = TextEditingController();
  final TextEditingController _hargaC = TextEditingController();
  final TextEditingController _hppSementaraC = TextEditingController();
  final TextEditingController _supplierC = TextEditingController();
  SupplierData? _selectedSupplier;
  final TextEditingController _notaC = TextEditingController(text: 'NOTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
  DateTime _tanggal = DateTime.now();
  bool _isBesar = false;
  bool _isKoreksi = false;
  bool _isTempo = true;
  int _topDays = 30;

  @override
  void dispose() {
    _searchC.dispose();
    _qtyC.dispose();
    _hargaC.dispose();
    _hppSementaraC.dispose();
    _supplierC.dispose();
    _notaC.dispose();
    super.dispose();
  }

  Future<void> _pickTgl() async {
    final DateTime? p = await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (p != null) setState(() => _tanggal = p);
  }

  Future<void> _loadVariasi(int barangId) async {
    final db = ref.read(localDbProvider);
    final list = await db.barangDao.getVariasi(barangId);
    setState(() => _variasiList = list);
  }

  Future<void> _proses({bool next = false}) async {
    final LocalDatabase db = ref.read(localDbProvider);
    final dynamic ctrl = ref.read(inventoryControllerProvider);
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih barang')));
      return;
    }
    try {
      if (_isKoreksi) {
        final double hppBaru = double.tryParse(_hppSementaraC.text) ?? 0;
        if (hppBaru <= 0) throw Exception('HPP sementara wajib >0');
        await db.transaksiDao.koreksiHppTanpaBeli(
          barangId: _selected!.id,
          hppBaru: hppBaru,
          keterangan: 'KOREKSI_HPP Pasar ${_notaC.text} Tgl ${_tanggal.day}/${_tanggal.month}',
          tanggal: _tanggal,
        );
      } else {
        final int qty = int.tryParse(_qtyC.text) ?? 0;
        final double harga = double.tryParse(_hargaC.text) ?? 0;
        if (qty <= 0 || harga <= 0) throw Exception('Qty & Harga wajib');
        // LOGIKA LAMA TETAP
        await ctrl.beli(
          barangId: _selected!.id,
          qty: qty,
          harga: harga,
          isSatuanBesar: _isBesar,
          supplier: _selectedSupplier?.nama ?? _supplierC.text,
          tanggal: _tanggal,
          nota: _notaC.text,
        );

        // TAMBAHAN: Update variasi stok jika ada variasi dipilih
        if (_selectedVariasi != null) {
          await (db.update(db.barangVariasi)..where((t) => t.id.equals(_selectedVariasi!.id))).write(
            BarangVariasiCompanion(stok: drift.Value(_selectedVariasi!.stok + qty)),
          );
        }

        // KUNING: Sinkron ke HutangSupplier - semua nota cash/tempo tercatat
        final total = qty * harga;
        final jatuhTempo = _tanggal.add(Duration(days: _topDays));
        await db.hutangDao.insertHutang(HutangSupplierCompanion.insert(
          noNota: _notaC.text,
          supplierId: drift.Value(_selectedSupplier?.id ?? 0),
          supplierNama: _selectedSupplier?.nama ?? _supplierC.text,
          totalTagihan: total,
          sisaHutang: _isTempo ? total : 0,
          statusBayar: drift.Value(_isTempo ? 'BELUM_LUNAS' : 'LUNAS'),
          tipeBayar: drift.Value(_isTempo ? 'TEMPO' : 'CASH'),
          tanggalNota: drift.Value(_tanggal),
          jatuhTempo: jatuhTempo,
          topDays: drift.Value(_topDays),
        ));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isKoreksi
              ? 'HPP Sementara Rp ${_hppSementaraC.text} tgl ${_tanggal.day}/${_tanggal.month} masuk LOG'
              : 'Nota ${_notaC.text} HPP auto + Hutang ${_isTempo ? 'TEMPO' : 'LUNAS'} sinkron')));
      if (!next) {
        Navigator.pop(context);
      } else {
        setState(() {
          _qtyC.clear();
          _hargaC.clear();
          _hppSementaraC.clear();
          _notaC.text = 'NOTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota Masuk + HPP Auto + Log'), backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: _pickTgl,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(children: [const Icon(Icons.calendar_month_rounded, size: 18), const SizedBox(width: 8), Text('${_tanggal.day}/${_tanggal.month}/${_tanggal.year}', style: const TextStyle(fontWeight: FontWeight.bold))]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _notaC, decoration: const InputDecoration(labelText: 'No Nota', border: OutlineInputBorder(), isDense: true))),
          ]),
          const SizedBox(height: 16),
          Autocomplete<BarangData>(
            displayStringForOption: (BarangData b) => '${b.sku} - ${b.nama} - ${b.merek ?? ''}',
            optionsBuilder: (TextEditingValue v) async {
              if (v.text.isEmpty) return const Iterable<BarangData>.empty();
              return await ref.read(localDbProvider).barangDao.cariBarang(v.text);
            },
            onSelected: (BarangData s) {
              setState(() {
                _selected = s;
                _searchC.text = s.nama;
                _supplierC.text = s.supplierNama ?? '';
              });
              _loadVariasi(s.id);
            },
            fieldViewBuilder: (BuildContext c, TextEditingController ctrl, FocusNode f, void Function() _) {
              return TextField(
                controller: ctrl,
                focusNode: f,
                decoration: InputDecoration(
                  labelText: 'Cari Barang auto suggest', // BIRU
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { ctrl.clear(); setState(() { _selected = null; _variasiList = []; }); }),
                ),
                onChanged: (String v) => _searchC.text = v,
              );
            },
            optionsViewBuilder: (BuildContext c, void Function(BarangData) onSel, Iterable<BarangData> opts) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: SizedBox(
                    width: MediaQuery.of(c).size.width - 32,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: opts.length,
                      itemBuilder: (BuildContext _, int i) {
                        final BarangData b = opts.elementAt(i);
                        return ListTile(
                          title: Text('${b.nama} (${b.merek ?? '-'})', style: const TextStyle(fontWeight: FontWeight.bold)), // BIRU auto nyambung
                          subtitle: Text('SKU: ${b.sku} | Supplier: ${b.supplierNama ?? '-'} | Stok: ${b.stok} | HPP: Rp ${b.hppAverage.toStringAsFixed(0)}'),
                          onTap: () => onSel(b),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (_variasiList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonFormField<BarangVariasiData>(
                decoration: const InputDecoration(labelText: 'Pilih Variasi (Unlimited)', border: InputBorder.none, isDense: true),
                value: _selectedVariasi,
                items: _variasiList.map((v) => DropdownMenuItem(value: v, child: Text('${v.variasiNama} - Stok ${v.stok}'))).toList(),
                onChanged: (v) => setState(() => _selectedVariasi = v),
              ),
            ),
          const SizedBox(height: 12),
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_selected!.nama} • ${(_selected!.merek ?? '-')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('SKU: ${_selected!.sku} | Supplier: ${_selected!.supplierNama ?? '-'} | Merek: ${_selected!.merek ?? '-'}', style: const TextStyle(fontSize: 11)), // BIRU
                Text('Stok: ${_selected!.stok} | HPP: Rp ${_selected!.hppAverage.toStringAsFixed(0)} | ${_selected!.satuanTerkecil}/${_selected!.satuanBesar} isi ${_selected!.konversi}', style: const TextStyle(fontSize: 11)),
                Text('Ecer Rp ${_selected!.hargaEcer.toStringAsFixed(0)} | Agen Rp ${_selected!.hargaAgen.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                if (_selectedVariasi != null) Text('Variasi: ${_selectedVariasi!.variasiNama} Stok Var: ${_selectedVariasi!.stok}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ]),
            ),
          const SizedBox(height: 12),
          Row(children: [Checkbox(value: _isKoreksi, onChanged: (bool? v) => setState(() => _isKoreksi = v ?? false)), const Expanded(child: Text('Koreksi HPP Sementara (perubahan harga belum repeat beli) + Tgl + Log', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))]),
          if (_isKoreksi)
            TextField(controller: _hppSementaraC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Input HPP Sementara Baru * Tgl ${_tanggal.day}/${_tanggal.month}/${_tanggal.year}', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.price_change_rounded)))
          else ...[
            TextField(controller: _qtyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty Masuk *', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            TextField(controller: _hargaC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Beli per ${_isBesar ? "Besar" : "Pcs"} *', border: const OutlineInputBorder()), onChanged: (_) => setState(() {})),
            const SizedBox(height: 8),
            if (_selected != null && _qtyC.text.isNotEmpty && _hargaC.text.isNotEmpty)
              Builder(builder: (_) {
                final int oldS = _selected!.stok;
                final double oldH = _selected!.hppAverage;
                final int q = int.tryParse(_qtyC.text) ?? 0;
                final double h = double.tryParse(_hargaC.text) ?? 0;
                if (q == 0 || h == 0) return const SizedBox.shrink();
                final double newH = oldS <= 0 ? h : ((oldS * oldH) + (q * h)) / (oldS + q);
                return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HPP Baru Auto: Rp ${newH.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('Rumus: ($oldS x ${oldH.toStringAsFixed(0)} + $q x $h) / ${oldS + q}', style: const TextStyle(fontSize: 11))]));
              }),
          ],
          const SizedBox(height: 12),
          // Supplier auto suggest - BIRU
          Consumer(builder: (context, ref, _) {
            return Autocomplete<SupplierData>(
              displayStringForOption: (s) => s.nama,
              optionsBuilder: (TextEditingValue v) async {
                final all = await ref.read(localDbProvider).supplierDao.getAll();
                if (v.text.isEmpty) return all;
                return all.where((e) => e.nama.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (s) {
                setState(() {
                  _selectedSupplier = s;
                  _supplierC.text = s.nama;
                  _topDays = s.topDefault;
                });
              },
              fieldViewBuilder: (c, ctrl, f, _) {
                if (_supplierC.text.isNotEmpty && ctrl.text.isEmpty) ctrl.text = _supplierC.text;
                return TextField(controller: ctrl, focusNode: f, decoration: const InputDecoration(labelText: 'Supplier - auto nyambung', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_shipping)), onChanged: (v) => _supplierC.text = v);
              },
            );
          }),
          const SizedBox(height: 8),
          if (!_isKoreksi)
            Row(children: [
              Checkbox(value: _isBesar, onChanged: (bool? v) => setState(() => _isBesar = v ?? false)),
              Text(_isBesar ? 'Satuan Besar x${_selected?.konversi ?? 1}' : 'Satuan Kecil Pcs'),
              const Spacer(),
              Checkbox(value: _isTempo, onChanged: (v) => setState(() => _isTempo = v ?? true)),
              const Text('Tempo?'),
              if (_isTempo) SizedBox(width: 60, child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${_topDays}hr', border: const OutlineInputBorder(), isDense: true), onChanged: (v) => _topDays = int.tryParse(v) ?? 30)),
            ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => _proses(next: false), icon: const Icon(Icons.save), label: Text(_isKoreksi ? 'SIMPAN KOREKSI HPP + LOG' : 'SIMPAN & TUTUP'))), // KUNING
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), side: const BorderSide(color: Color(0xFF0F172A))), onPressed: () => _proses(next: true), icon: const Icon(Icons.skip_next_rounded), label: const Text('SIMPAN & NEXT'))),
          ]),
        ]),
      ),
    );
  }
}
