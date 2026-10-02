import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/piutang_provider.dart';

class PiutangScreen extends ConsumerWidget {
  const PiutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piutangAsync = ref.watch(piutangListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Piutang Pelanggan'),
        elevation: 1,
      ),
      body: piutangAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gagal memuat data piutang: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada piutang pelanggan aktif.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final grandTotalPiutang = groups.fold<double>(
            0.0,
            (sum, item) => sum + item.totalPiutang,
          );

          return Column(
            children: [
              // Header Summary Total Piutang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.orange.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Piutang Pelanggan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${groups.length} Pelanggan (${groups.fold<int>(0, (sum, g) => sum + g.jumlahNota)} Transaksi)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      'Rp ${grandTotalPiutang.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List Pelanggan & Rincian Nota Transaksi
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          group.namaPelanggan,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${group.jumlahNota} Nota Transaksi'),
                        trailing: Text(
                          'Rp ${group.totalPiutang.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.deepOrange,
                          ),
                        ),
                        children: group.daftarTransaksi.map((trx) {
                          final subtotal = trx.qtyPcs * trx.hargaJualPerSatuanSnapshot;
                          final tgl = trx.tanggal.toLocal().toString().split('.')[0];
                          return Container(
                            color: Colors.grey.shade50,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              leading: const Icon(Icons.point_of_sale, color: Colors.grey),
                              title: Text('Transaksi #${trx.id} (${trx.tipe})'),
                              subtitle: Text('Qty: ${trx.qtyPcs} Pcs\nTanggal: $tgl'),
                              isThreeLine: true,
                              trailing: Text(
                                'Rp ${subtotal.toStringAsFixed(0)}',
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
