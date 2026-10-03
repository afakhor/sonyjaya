import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';

class SupplierDetailScreen extends ConsumerWidget {
  final SupplierData supplier;
  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(supplier.nama),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(localDbProvider).supplierDao.getInfoSupplier(supplier.nama),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

          final data = snap.data!;
          final List<BarangData> barangs = data['daftarBarang'] as List<BarangData>;
          final List<PurchaseOrder> pos = data['daftarPo'] as List<PurchaseOrder>;
          final double totalBelanja = data['totalBelanja'] as double;
          final double totalHutang = data['totalHutang'] as double;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // HEADER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.store_rounded, color: Color(0xFF2563EB))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(supplier.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text('Kontak: ${supplier.kontak?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Text('Alamat: ${supplier.alamat?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ])),
                      ],
                    ),
                    const Divider(height: 24),
                    _rowInfo('Total Belanja', 'Rp ${totalBelanja.toStringAsFixed(0)}', Colors.green),
                    const SizedBox(height: 6),
                    _rowInfo('Total Hutang Belum Lunas', 'Rp ${totalHutang.toStringAsFixed(0)}', totalHutang > 0? Colors.red : Colors.grey),
                    const SizedBox(height: 6),
                    _rowInfo('Jumlah Transaksi Beli', '${data['jumlahTransaksi']} kali', Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Barang yang pernah dibeli dari supplier ini:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              if (barangs.isEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))), child: const Text('Belum ada barang.', style: TextStyle(fontSize: 12, color: Colors.grey))),
             ...barangs.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('SKU: ${b.sku?? '-'} | Stok: ${b.stok} | HPP: Rp ${b.hppAverage.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ])),
                  const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                ]),
              )),

              const SizedBox(height: 20),
              const Text('PO Hutang Belum Lunas:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              if (pos.isEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))), child: const Text('Tidak ada hutang.', style: TextStyle(fontSize: 12, color: Colors.green))),
             ...pos.map((po) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PO ${po.noPo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${po.tanggalPo.toString().split(' ')[0]} | ${po.statusBayar} | Rp ${po.totalKeseluruhan.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                  ])),
                  const Icon(Icons.money_off_rounded, color: Colors.red, size: 18),
                ]),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _rowInfo(String label, String value, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}