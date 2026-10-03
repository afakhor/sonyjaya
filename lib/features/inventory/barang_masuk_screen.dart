import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import 'providers/inventory_provider.dart';

class BarangMasukScreen extends ConsumerStatefulWidget {
  const BarangMasukScreen({super.key});
  @override
  ConsumerState<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends ConsumerState<BarangMasukScreen> {
  final _searchController = TextEditingController();
  BarangData? _selectedBarang;
  final _qtyC = TextEditingController();
  final _hargaC = TextEditingController();
  final _supplierC = TextEditingController();
  final _notaC = TextEditingController(text: 'NOTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
  DateTime _tanggal = DateTime.now();
  bool _isSatuanBesar = false;
  bool _isAddingNew = false;
  final _namaBaruC = TextEditingController();
  final _skuBaruC = TextEditingController();
  final _merekBaruC = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _qtyC.dispose();
    _hargaC.dispose();
    _supplierC.dispose();
    _notaC.dispose();
    _namaBaruC.dispose();
    _skuBaruC.dispose();
    _merekBaruC.dispose();
    super.dispose();
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _prosesBeli({bool closeAfter = true}) async {
    if (_selectedBarang == null && !_isAddingNew) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih barang dulu')));
      return;
    }
    final qty = int.tryParse(_qtyC.text) ?? 0;
    final harga = double.tryParse(_hargaC.text) ?? 0;
    if (qty <= 0 || harga <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Qty & Harga harus > 0')));
      return;
    }
    final db = ref.read(localDbProvider);
    final controller = ref.read(inventoryControllerProvider);
    try {
      int barangId;
      if (_isAddingNew) {
        final comp = BarangCompanion(
          nama: drift.Value(_namaBaruC.text.trim()),
          sku: drift.Value(_skuBaruC.text.isEmpty ? null : _skuBaruC.text.trim()),
          merek: drift.Value(_merekBaruC.text.isEmpty ? null : _merekBaruC.text.trim()),
          satuanTerkecil: const drift.Value('Pcs'),
          satuanBesar: const drift.Value('Set'),
          stok: const drift.Value(0),
          hppAverage: const drift.Value(0),
          hargaEcer: drift.Value(harga * 1.3),
        );
        barangId = await db.barangDao.insertBarang(comp);
      } else {
        barangId = _selectedBarang!.id;
      }
      if (_supplierC.text.isNotEmpty) {
        await db.supplierDao.upsertSupplier(_supplierC.text.trim());
      }
      await controller.beli(
        barangId: barangId,
        qty: qty,
        harga: harga,
        isSatuanBesar: _isSatuanBesar,
        supplier: _supplierC.text.isEmpty ? null : _supplierC.text.trim(),
        tanggal: _tanggal,
        nota: _notaC.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Nota ${_notaC.text} Tgl ${_tanggal.day}/${_tanggal.month} | HPP auto')));
      if (closeAfter) {
        Navigator.pop(context);
      } else {
        setState(() {
          _qtyC.clear();
          _hargaC.clear();
          _selectedBarang = null;
          _isAddingNew = false;
          _searchController.clear();
          _namaBaruC.clear();
          _skuBaruC.clear();
          _merekBaruC.clear();
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
      appBar: AppBar(title: const Text('Nota Masuk + HPP Auto + Log'), backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), elevation: 0),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: _pickTanggal,
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
            displayStringForOption: (b) => b.nama,
            optionsBuilder: (val) async {
              if (val.text.isEmpty) return const Iterable<BarangData>.empty();
              final db = ref.read(localDbProvider);
              return await db.barangDao.cariBarang(val.text);
            },
            onSelected: (s) => setState(() {
              _selectedBarang = s;
              _isAddingNew = false;
              _searchController.text = s.nama;
            }),
            fieldViewBuilder: (context, controller, focusNode, _) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Cari Barang auto suggest',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () {
                    controller.clear();
                    setState(() { _selectedBarang = null; _isAddingNew = false; });
                  }),
                ),
                onChanged: (val) => _searchController.text = val,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: options.length + 1,
                      itemBuilder: (context, index) {
                        if (index == options.length) {
                          return ListTile(
                            leading: const Icon(Icons.add_circle, color: Colors.green),
                            title: Text('Tambah Baru "${_searchController.text}"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            onTap: () {
                              setState(() { _isAddingNew = true; _namaBaruC.text = _searchController.text; _selectedBarang = null; });
                              FocusScope.of(context).unfocus();
                            },
                          );
                        }
                        final b = options.elementAt(index);
                        return ListTile(
                          title: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Stok: ${b.stok} | HPP: Rp ${b.hppAverage.toStringAsFixed(0)}'),
                          onTap: () => onSelected(b),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_selectedBarang != null)
            Card(color: Colors.blue.shade50, child: ListTile(title: Text(_selectedBarang!.nama, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Stok: ${_selectedBarang!.stok} | HPP: Rp ${_selectedBarang!.hppAverage.toStringAsFixed(0)} | ${_selectedBarang!.satuanTerkecil}/${_selectedBarang!.satuanBesar} isi ${_selectedBarang!.konversi}'))),
          if (_isAddingNew)
            Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              const Text('Master Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 8),
              TextField(controller: _namaBaruC, decoration: const InputDecoration(labelText: 'Nama Baru *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: TextField(controller: _skuBaruC, decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(child: TextField(controller: _merekBaruC, decoration: const InputDecoration(labelText: 'Merek', border: OutlineInputBorder())))])
            ]))),
          if (_selectedBarang != null || _isAddingNew) ...[
            const Divider(height: 32),
            if (_selectedBarang != null && _qtyC.text.isNotEmpty && _hargaC.text.isNotEmpty)
              Builder(builder: (context) {
                final oldStok = _selectedBarang!.stok;
                final oldHpp = _selectedBarang!.hppAverage;
                final qty = int.tryParse(_qtyC.text) ?? 0;
                final harga = double.tryParse(_hargaC.text) ?? 0;
                if (qty==0||harga==0) return const SizedBox.shrink();
                final newHpp = oldStok <= 0 ? harga : ((oldStok * oldHpp) + (qty * harga)) / (oldStok + qty);
                return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Preview HPP Baru Auto: Rp ${newHpp.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)), Text('Rumus: ($oldStok x ${oldHpp.toStringAsFixed(0)} + $qty x $harga) / ${oldStok + qty}', style: const TextStyle(fontSize: 11))] ));
              }),
            TextField(controller: _qtyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty Masuk *', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            TextField(controller: _hargaC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Beli per ${_isSatuanBesar ? "Besar" : "Pcs"} *', border: const OutlineInputBorder()), onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (val) async {
                final db = ref.read(localDbProvider);
                final all = await (db.select(db.supplier)).get();
                return all.map((e) => e.nama).where((s) => s.toLowerCase().contains(val.text.toLowerCase()));
              },
              fieldViewBuilder: (c, controller, focus, _) => TextField(controller: controller, focusNode: focus, decoration: const InputDecoration(labelText: 'Supplier', prefixIcon: Icon(Icons.local_shipping), border: OutlineInputBorder()), onChanged: (v) => _supplierC.text = v),
              onSelected: (s) => _supplierC.text = s,
            ),
            const SizedBox(height: 12),
            Row(children: [Checkbox(value: _isSatuanBesar, onChanged: (v) => setState(() => _isSatuanBesar = v ?? false)), Text(_isSatuanBesar ? 'Satuan Besar x${_selectedBarang?.konversi ?? 1}' : 'Satuan Kecil Pcs')]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _prosesBeli(closeAfter: true), icon: const Icon(Icons.save), label: const Text('SIMPAN & TUTUP'))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), side: const BorderSide(color: Color(0xFF0F172A)), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _prosesBeli(closeAfter: false), icon: const Icon(Icons.skip_next_rounded), label: const Text('SIMPAN & NEXT'))),
            ]),
          ],
        ]),
      ),
    );
  }
}