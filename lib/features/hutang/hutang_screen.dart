import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'providers/hutang_provider.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../../core/database/local_database.dart'; // Import DB untuk Companion

class HutangScreen extends ConsumerWidget {
  const HutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hutangAsync = ref.watch(hutangListProvider);
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Hutang Supplier'),
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
                  Text('Aman! Tidak ada hutang ke supplier.', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                    const Text('Total Kewajiban:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade200,
                          child: const Icon(Icons.business, color: Colors.black87),
                        ),
                        title: Text(summary.namaSupplier, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${summary.jumlahPo} Nota PO Belum Lunas'),
                        trailing: Text(
                          'Rp ${summary.totalHutang.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                        ),
                        onTap: () => _showDetailHutang(context, ref, summary),
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

  void _showDetailHutang(BuildContext context, WidgetRef ref, HutangSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pelunasan: ${summary.namaSupplier}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...summary.daftarPo.map((po) => ListTile(
              title: Text('PO #${po.noPo}'),
              trailing: Text('Rp ${po.totalKeseluruhan.toStringAsFixed(0)}'),
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              onPressed: () async {
                final db = ref.read(localDbProvider);
                for (var po in summary.daftarPo) {
                  await (db.update(db.purchaseOrders)..where((p) => p.id.equals(po.id))).write(
                    PurchaseOrdersCompanion(statusBayar: drift.Value('LUNAS')), // Fixed Drift Value
                  );
                }
                ref.invalidate(hutangListProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('LUNASKAN HUTANG'),
            ),
          ],
        ),
      ),
    );
  }
}
