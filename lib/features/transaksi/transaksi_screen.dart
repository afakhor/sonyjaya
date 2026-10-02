import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/transaksi_provider.dart';

class TransaksiScreen extends ConsumerWidget {
  const TransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksiAsync = ref.watch(transaksiStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi Penjualan'),
      ),
      body: transaksiAsync.when(
        data: (listTransaksi) {
          if (listTransaksi.isEmpty) {
            return const Center(child: Text('Belum ada transaksi penjualan.'));
          }

          final double totalLunas = listTransaksi
              .where((t) =>
                  t.tipe.toLowerCase() == 'lunas' ||
                  t.tipe.toLowerCase() == 'eceran' ||
                  t.tipe.toLowerCase() == 'eceran_kasir')
              .fold(0.0, (sum, item) => sum + (item.qtyPcs * item.hargaJualPerPcs));

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Penjualan Lunas:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      'Rp ${totalLunas.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listTransaksi.length,
                  itemBuilder: (context, index) {
                    final item = listTransaksi[index];
                    final totalItem = item.qtyPcs * item.hargaJualPerPcs;
                    final tgl = item.tanggal.toLocal().toString().split('.')[0];

                    return ListTile(
                      title: Text('Trx #${item.id} - ${item.tipe.toUpperCase()}'),
                      subtitle: Text('$tgl | Qty: ${item.qtyPcs} pcs'),
                      trailing: Text(
                        'Rp ${totalItem.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
