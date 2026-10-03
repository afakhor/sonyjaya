import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'supplier_detail_screen.dart';

final supplierListProvider = StreamProvider<List<SupplierData>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.supplierDao.watchAll();
});

class SupplierScreen extends ConsumerWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(supplierListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Master Supplier'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: supplierAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Belum ada supplier.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Supplier otomatis ke-simpan saat\nkamu input barang masuk + HPP',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (c, i) {
              final s = list[i];
              return FutureBuilder<Map<String, dynamic>>(
                future: ref.read(localDbProvider).supplierDao.getInfoSupplier(s.nama),
                builder: (context, snap) {
                  final totalBelanja = snap.data?['totalBelanja']?? 0.0;
                  final totalHutang = snap.data?['totalHutang']?? 0.0;
                  final jumlahTx = snap.data?['jumlahTransaksi']?? 0;

                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: s))),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.store_rounded, color: Color(0xFF2563EB)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(s.kontak?? '-', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _chip('Belanja Rp ${totalBelanja.toStringAsFixed(0)}', const Color(0xFFF0FDF4), const Color(0xFF15803D)),
                                    const SizedBox(width: 6),
                                    if (totalHutang > 0) _chip('Hutang Rp ${totalHutang.toStringAsFixed(0)}', const Color(0xFFFEF2F2), const Color(0xFFB91C1C)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$jumlahTx tx', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}