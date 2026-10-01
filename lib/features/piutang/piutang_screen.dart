import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/piutang_provider.dart';
import '../inventory/providers/inventory_provider.dart';

class PiutangScreen extends ConsumerWidget {
  const PiutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piutangAsync = ref.watch(piutangListProvider);
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Bon & Piutang Pelanggan'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: piutangAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 12),
                  Text('Aman! Tidak ada piutang atau bon aktif saat ini.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // Hitung total keseluruhan piutang toko
          double grandTotalPiutang = summaries.fold(0, (sum, item) => sum + item.totalPiutang);

          return Column(
            children: [
              // Banner Informasi Total Piutang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.amber.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Piutang Luar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rp ${grandTotalPiutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
                  ],
                ),
              ),
              
              // Daftar Pelanggan Berbon
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: const Icon(Icons.person, color: Colors.red),
                        ),
                        title: Text(
                          summary.namaPelanggan,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${summary.jumlahNota} Nota Belum Lunas'),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${summary.totalPiutang.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                            ),
                            const SizedBox(height: 4),
                            const Text('Ketuk untuk Detail', style: TextStyle(fontSize: 11, color: Colors.blue)),
                          ],
                        ),
                        onTap: () {
                          _showDetailPelangganBon(context, ref, summary);
                        },
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

  void _showDetailPelangganBon(BuildContext context, WidgetRef ref, PiutangSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rincian Bon: ${summary.namaPelanggan}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: summary.daftarTransaksi.length,
                itemBuilder: (context, index) {
                  final trx = summary.daftarTransaksi[index];
                  return ListTile(
                    dense: true,
                    title: Text('Nota #${trx.id} - ${trx.tanggal}'),
                    trailing: Text('Rp ${trx.totalHarga.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Tagihan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Rp ${summary.totalPiutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                // Logika Pelunasan Piutang (Update status transaksi jadi LUNAS di Database)
                final db = ref.read(localDbProvider);
                for (var trx in summary.daftarTransaksi) {
                  await (db.update(db.transaksi)..where((t) => t.id.equals(trx.id))).write(
                    TransaksiCompanion(statusBayar: const Value('LUNAS')),
                  );
                }
                ref.invalidate(piutangListProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Piutang ${summary.namaPelanggan} berhasil dilunaskan!')),
                  );
                }
              },
              child: const Text('LUNASKAN SEMUA BON INI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
