import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/local_database.dart';
import 'providers/supplier_provider_v8.dart';

class MasterSupplierScreenFix extends ConsumerStatefulWidget {
  const MasterSupplierScreenFix({super.key});
  @override ConsumerState<MasterSupplierScreenFix> createState() => _MasterSupplierScreenFixState();
}

class _MasterSupplierScreenFixState extends ConsumerState<MasterSupplierScreenFix> {
  final searchCtrl = TextEditingController();

  Future<void> _showAddEditDialog({SupplierData? existing}) async {
    final namaCtrl = TextEditingController(text: existing?.nama ?? '');
    final kontakCtrl = TextEditingController(text: existing?.kontak ?? '');
    final alamatCtrl = TextEditingController(text: existing?.alamat ?? '');
    final topCtrl = TextEditingController(text: (existing?.topDefault ?? 30).toString());

    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Edit Supplier' : 'Tambah Supplier', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Supplier *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Wajib' : null),
              const SizedBox(height: 12),
              TextFormField(controller: kontakCtrl, decoration: const InputDecoration(labelText: 'Kontak', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: alamatCtrl, decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: topCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'TOP Default (hari)', border: OutlineInputBorder())),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final db = ref.read(localDbProvider);
              if (isEdit) {
                await db.supplierDao.updateSupplier(existing.copyWith(
                  nama: namaCtrl.text.trim(),
                  kontak: drift.Value(kontakCtrl.text.trim()),
                  alamat: drift.Value(alamatCtrl.text.trim()),
                  topDefault: int.tryParse(topCtrl.text) ?? 30,
                ));
              } else {
                await db.supplierDao.insertSupplier(SupplierCompanion.insert(
                  nama: namaCtrl.text.trim(),
                  kontak: drift.Value(kontakCtrl.text.trim()),
                  alamat: drift.Value(alamatCtrl.text.trim()),
                  topDefault: drift.Value(int.tryParse(topCtrl.text) ?? 30),
                ));
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Master Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        color: const Color(0xFFF9FAFB),
        child: Column(children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari supplier...', // BIRU lingkar - auto suggest
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ),
          Expanded(
            child: suppliers.when(
              data: (list) {
                var filtered = list;
                if (searchCtrl.text.isNotEmpty) {
                  filtered = list.where((s) => s.nama.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
                }
                if (filtered.isEmpty) {
                  return const Center(child: Text('Belum ada supplier, tap + Tambah'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: ListTile(
                        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.store, color: Color(0xFF3B82F6))),
                        title: Text(s.nama, style: const TextStyle(fontWeight: FontWeight.bold)), // BIRU - nama barang / supplier auto nyambung
                        subtitle: Text(s.kontak ?? '- • TOP ${s.topDefault} hari'),
                        trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showAddEditDialog(existing: s)), // MERAH-BIRU FIX: bisa klik edit
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error $e')),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditDialog(), // MERAH-BIRU FIX: bisa klik tambah
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Supplier'),
      ),
    );
  }
}
