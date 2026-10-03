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
  final _searchController = TextEditingController();
  BarangData? _selectedBarang;
  final _qtyC = TextEditingController();
  final _hargaC = TextEditingController();
  final _supplierC = TextEditingController();
  bool _isSatuanBesar = false;
  bool _isAddingNew = false;
  final _namaBaruC = TextEditingController();
  final _skuBaruC = TextEditingController();
  final _merekBaruC = TextEditingController();

  Future<void> _prosesBeli() async {
    if (_selectedBarang == null &&!_isAddingNew) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih barang dulu')));
      return;
    }
    final qty = int.tryParse(_qtyC.text)?? 0;
    final harga = double.tryParse(_hargaC.text)?? 0;
    if (qty <= 0 || harga <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Qty & Harga harus > 0')));
      return;
    }
    final db = ref.read(localDbProvider);
    final controller = ref.read(inventoryControllerProvider);
    try {
      int barangId;
      if (_isAddingNew) {
        final comp = BarangCompanion(nama: drift.Value(_namaBaruC.text), sku: drift.Value(_skuBaruC.text.isEmpty? null : _skuBaruC.text), merek: drift.Value(_merekBaruC.text.isEmpty? null : _merekBaruC.text), satuanTerkecil: const drift.Value('Pcs'), satuanBesar: const drift.Value('Set'), stok: const drift.Value(0), hppAverage: const drift.Value(0), hargaEcer: drift.Value(harga * 1.3));
        barangId = await db.barangDao.insertBarang(comp);
      } else {
        barangId = _selectedBarang!.id;
      }
      if (_supplierC.text.isNotEmpty) {
        await db.supplierDao.upsertSupplier(_supplierC.text.trim());
      }
      await controller.beli(barangId: barangId, qty: qty, harga: harga, isSatuanBesar: _isSatuanBesar, supplier: _supplierC.text.isEmpty? null : _supplierC.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil! Stok & HPP ${_isAddingNew? _namaBaruC.text : _selectedBarang!.nama} terupdate')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Barang + Beli Supplier + HPP'), backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Autocomplete<BarangData>(
          displayStringForOption: (b) => b.nama,
          optionsBuilder: (val) async {
            if (val.text.isEmpty) return const Iterable<BarangData>.empty();
            final db = ref.read(localDbProvider);
            return await db.barangDao.cariBarang(val.text);
          },
          onSelected: (BarangData s) { setState(() { _selectedBarang = s; _isAddingNew = false; _searchController.text = s.nama; }); },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _searchController.text = controller.text;
            return TextField(controller: controller, focusNode: focusNode, decoration: InputDecoration(labelText: 'Cari Barang (nama/sku/merek) auto suggest', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { controller.clear(); setState(() { _selectedBarang = null; _isAddingNew = false; }); }), border: const OutlineInputBorder()), onChanged: (val) => _searchController.text = val);
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(alignment: Alignment.topLeft, child: Material(elevation: 4, child: SizedBox(width: MediaQuery.of(context).size.width - 32, child: ListView.builder(padding: EdgeInsets.zero, shrinkWrap: true, itemCount: options.length + 1, itemBuilder: (context, index) {
              if (index == options.length) {
                return ListTile(leading: const Icon(Icons.add_circle, color: Colors.green), title: Text('Tambah Barang Baru "${_searchController.text}"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)), onTap: () { setState(() { _isAddingNew = true; _namaBaruC.text = _searchController.text; _selectedBarang = null; }); FocusScope.of(context).unfocus(); });
              }
              final barang = options.elementAt(index);
              return ListTile(title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('SKU: ${barang.sku?? '-'} | Stok: ${barang.stok} | HPP: Rp ${barang.hppAverage.toStringAsFixed(0)}'), onTap: () => onSelected(barang));
            }))));
          },
        ),
        const SizedBox(height: 16),
        if (_selectedBarang!= null) Card(color: Colors.blue.shade50, child: ListTile(title: Text(_selectedBarang!.nama, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Stok: ${_selectedBarang!.stok} | HPP: Rp ${_selectedBarang!.hppAverage.toStringAsFixed(0)} | Satuan: ${_selectedBarang!.satuanTerkecil}/${_selectedBarang!.satuanBesar} isi ${_selectedBarang!.konversi}'), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedBarang = null)))),
        if (_isAddingNew) Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [const Text('Tambah Master Barang Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)), const SizedBox(height: 8), TextField(controller: _namaBaruC, decoration: const InputDecoration(labelText: 'Nama Barang Baru *', border: OutlineInputBorder())), const SizedBox(height: 8), Row(children: [Expanded(child: TextField(controller: _skuBaruC, decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder()))), const SizedBox(width: 8), Expanded(child: TextField(controller: _merekBaruC, decoration: const InputDecoration(labelText: 'Merek', border: OutlineInputBorder())))] )] ))),
        const Divider(height: 32),
        if (_selectedBarang!= null || _isAddingNew)...[
          TextField(controller: _qtyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty Masuk *', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _hargaC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Beli per ${_isSatuanBesar? "Satuan Besar" : "Pcs"} *', border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          Autocomplete<String>(
            optionsBuilder: (val) async {
              final db = ref.read(localDbProvider);
              final all = await (db.select(db.supplier)).get();
              final suppliers = all.map((e) => e.nama).toList();
              return suppliers.where((s) => s.toLowerCase().contains(val.text.toLowerCase()));
            },
            fieldViewBuilder: (c, controller, focus, submit) {
              return TextField(controller: controller, focusNode: focus, decoration: const InputDecoration(labelText: 'Supplier (auto suggest dari master)', prefixIcon: Icon(Icons.local_shipping), border: OutlineInputBorder()), onChanged: (v) => _supplierC.text = v);
            },
            onSelected: (s) => _supplierC.text = s,
          ),
          const SizedBox(height: 12),
          Row(children: [Checkbox(value: _isSatuanBesar, onChanged: (v) => setState(() => _isSatuanBesar = v?? false)), Text(_isSatuanBesar? 'Beli Satuan Besar (konversi x${_selectedBarang?.konversi?? 1})' : 'Beli Satuan Kecil (Pcs)')]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _prosesBeli, icon: const Icon(Icons.save), label: Text(_isAddingNew? 'SIMPAN BARU + UPDATE HPP' : 'BELI & UPDATE HPP ${_selectedBarang?.nama?? ''}'))),
        ],
      ])),
    );
  }
}