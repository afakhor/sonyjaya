import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/transaksi_provider.dart';

class TransaksiScreen extends ConsumerWidget {
  const TransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksiAsync = ref.watch(transaksiStreamProvider);
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat & Buku Transaksi Toko'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: transaksiAsync.when(
        data: (listTransaksi) {
          if (listTransaksi.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada riwayat transaksi tercatat.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // Hitung total omset dari transaksi sukses/lunas
          double totalOmset = listTransaksi
              .where((t) => t.statusBayar == 'LUNAS')
              .fold(0, (sum, item) => sum + item.totalHarga);

          return Column(
            children: [
              // Banner Rekap Omset
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Omset Masuk (Lunas):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rp ${totalOmset.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),

              // Daftar Nota Transaksi
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: listTransaksi.length,
                  itemBuilder: (context, index) {
                    final trx = listTransaksi[index];
                    final isLunas = trx.statusBayar == 'LUNAS';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: isLunas ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isLunas ? Icons.check : Icons.hourglass_top,
                            color: isLunas ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          'Nota #${trx.id} - ${trx.namaRelasi ?? 'Pelanggan Umum'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Tipe: ${trx.tipe.toUpperCase()} | Tgl: ${trx.tanggal}'),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${trx.totalHarga.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isLunas ? Colors.black87 : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLunas ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                trx.statusBayar,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isLunas ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
