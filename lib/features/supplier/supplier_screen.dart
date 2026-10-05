import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'supplier_detail_screen.dart';

class SupplierScreen extends ConsumerWidget {
  const SupplierScreen({super.key});

  Future<void> _showAddSupplier(BuildContext context, WidgetRef ref) async {
    final namaCtrl = TextEditingController();
    final kontakCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();

    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tambah Supplier Baru'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Supplier *', prefixIcon: Icon(Icons.store_rounded), border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
            const SizedBox(height: 12),
            TextField(controller: kontakCtrl, decoration: const InputDecoration(labelText: 'No HP / WA', prefixIcon: Icon(Icons.phone_rounded), border: OutlineInputBorder(), hintText: '0812xxxx'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: alamatCtrl, decoration: const InputDecoration(labelText: 'Alamat Lengkap', prefixIcon: Icon(Icons.location_on_rounded), border: OutlineInputBorder()), maxLines: 3),
          ]),
        ),
        actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Batal')), ElevatedButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Simpan'))],
      ),
    );

    if(res==true && namaCtrl.text.trim().isNotEmpty){
      final db = ref.read(localDbProvider);
      await db.supplierDao.upsertSupplier(namaCtrl.text.trim());
      // langsung update kontak alamat
      final sup = await (db.select(db.supplier)..where((s)=>s.nama.equals(namaCtrl.text.trim()))).getSingle();
      await db.supplierDao.updateKontakAlamat(sup.id, kontakCtrl.text.trim(), alamatCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(allSupplierStreamProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Master Supplier', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>_showAddSupplier(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Supplier'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: supplierAsync.when(
        data: (list){
          if(list.isEmpty) return const Center(child: Text('Belum ada supplier.\nKlik + Tambah Supplier atau otomatis keisi saat input nota', textAlign: TextAlign.center));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_,__)=> const SizedBox(height: 10),
            itemBuilder: (c,i){
              final s = list[i];
              return FutureBuilder<Map<String,dynamic>>(
                future: ref.read(localDbProvider).supplierDao.getInfoSupplier(s.nama),
                builder: (context,snap){
                  final totalBelanja = snap.data?['totalBelanja']??0.0;
                  return InkWell(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> SupplierDetailScreen(supplier: s))),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(children: [
                        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront_rounded, color: Color(0xFF2563EB))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 2),
                          Row(children: [const Icon(Icons.phone_rounded, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(s.kontak?.isEmpty==true? 'Kontak: - (klik untuk isi)' : s.kontak!, style: TextStyle(fontSize: 11, color: s.kontak?.isEmpty==true? Colors.red : Colors.grey.shade600))]),
                          Row(children: [const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(s.alamat?.isEmpty==true? 'Alamat: -' : s.alamat!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          const SizedBox(height: 4),
                          Text('Total Belanja Rp ${totalBelanja.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
                        ])),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ]),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: ()=> const Center(child: CircularProgressIndicator()),
        error: (e,_)=> Center(child: Text('Error: $e')),
      ),
    );
  }
}