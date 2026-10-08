import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/supplier_provider.dart';

class SupplierScreen extends ConsumerStatefulWidget {
  const SupplierScreen({super.key});
  @override ConsumerState<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends ConsumerState<SupplierScreen> {
  final searchCtrl = TextEditingController();

  @override void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    final supplierList = ref.watch(supplierStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white, // FIX ABU TUA FOTO KAMU -> PUTIH
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Master Supplier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Container(
        color: const Color(0xFFF9FAFB), // cantik, bukan abu tua #CCCCCC di foto kamu
        child: Column(
          children: [
            // Search rapi
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari supplier...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Colors.black, width: 1.2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: supplierList.when(
                data: (list) {
                  var filtered = list;
                  if (searchCtrl.text.isNotEmpty) {
                    filtered = list.where((s) => s.nama.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.local_shipping_outlined, size: 32, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 12),
                        const Text('Belum ada supplier', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Tap + Tambah Supplier di bawah', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ]),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.store, color: Color(0xFF3B82F6), size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(s.kontak ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                        ]),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
