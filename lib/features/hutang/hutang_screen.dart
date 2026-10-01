import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/hutang_provider.dart';
import '../inventory/providers/inventory_provider.dart';

class HutangScreen extends ConsumerWidget {
  const HutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hutangAsync = ref.watch(hutangListProvider);
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Hutang Supplier / Distributor'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: hutangAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 12),
                  Text('Aman! Tidak ada hutang ke supplier saat ini.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          double grandTotalHutang = summaries.fold(0, (sum, item) => sum + item.totalHutang);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Kewajiban Hutang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rp ${grandTotalHutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange)),
                  ],
                ),
              ),
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
                          backgroundColor: Colors.orange.shade200,
                          child: const Icon(Icons.business, color: Colors.black87),
                        ),
                        title: Text(summary.namaSupplier, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${summary.jumlahPo} Nota PO Belum Lunas'),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${summary.totalHutang.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                            ),
                            const SizedBox(height: 4),
                            const Text('Ketuk untuk Bayar', style: TextStyle(fontSize: 11, color: Colors.blue)),
                          ],
                        ),
                        onTap: () {
                          _showDetailHutangSupplier(context, ref, summary);
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

  void _showDetailHutangSupplier(BuildContext context, WidgetRef ref, HutangSummary summary) {
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
            Text('Pelunasan Hutang: ${summary.namaSupplier}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: summary.daftarPo.length,
                itemBuilder: (context, index) {
                  final po = summary.daftarPo[index];
                  return ListTile(
                    dense: true,
                    title: Text('PO #${po.noPo} - ${po.tanggal}'),
                    trailing: Text('Rp ${po.totalNilai.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Rp ${summary.totalHutang.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                final db = ref.read(localDbProvider);
                for (var po in summary.daftarPo) {
                  await (db.update(db.purchaseOrders)..where((p) => p.id.equals(po.id))).write(
                    PurchaseOrdersCompanion(statusBayar: const Value('LUNAS')),
                  );
                }
                ref.invalidate(hutangListProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hutang ke ${summary.namaSupplier} berhasil dilunasi!')),
                  );
                }
              },
              child: const Text('BAYAR / LUNASKAN HUTANG SUPPLIER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
