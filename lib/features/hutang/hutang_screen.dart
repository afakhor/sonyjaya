import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/hutang_provider.dart';

class HutangScreen extends ConsumerWidget {
  const HutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hutangAsync = ref.watch(hutangListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Hutang Vendor'),
        elevation: 1,
      ),
      body: hutangAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gagal memuat data hutang: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada hutang vendor aktif.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final grandTotalHutang = groups.fold<double>(
            0.0,
            (sum, item) => sum + item.totalHutang,
          );

          return Column(
            children: [
              // Header Summary Total Hutang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.red.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Hutang Vendor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${groups.length} Supplier (${groups.fold<int>(0, (sum, g) => sum + g.jumlahPo)} PO)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      'Rp ${grandTotalHutang.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List Supplier & Rincian PO
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Icon(Icons.store, color: Colors.white),
                        ),
                        title: Text(
                          group.namaSupplier,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${group.jumlahPo} Purchase Order (PO)'),
                        trailing: Text(
                          'Rp ${group.totalHutang.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                        children: group.daftarPo.map((po) {
                          // Menggunakan po.tanggalPo dari tabel PurchaseOrders
                          final tgl = po.tanggalPo.toLocal().toString().split('.')[0];
                          return Container(
                            color: Colors.grey.shade50,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              leading: const Icon(Icons.receipt_long, color: Colors.grey),
                              title: Text('PO #${po.noPo}'),
                              subtitle: Text('Tanggal: $tgl\nStatus Bayar: ${po.statusBayar} (${po.statusPo})'),
                              isThreeLine: true,
                              trailing: Text(
                                'Rp ${po.totalKeseluruhan.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
