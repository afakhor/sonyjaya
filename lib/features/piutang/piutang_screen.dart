import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'providers/piutang_provider.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../../core/database/local_database.dart'; // Import DB untuk Companion

class PiutangScreen extends ConsumerWidget {
  const PiutangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piutangAsync = ref.watch(piutangListProvider);
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Piutang Pelanggan'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: piutangAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) return const Center(child: Text('Aman! Tidak ada piutang.'));
          return ListView.builder(
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return ListTile(
                title: Text(summary.namaPelanggan),
                subtitle: Text('${summary.jumlahNota} Nota'),
                trailing: Text('Rp ${summary.totalPiutang.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red)),
                onTap: () => _showDetail(context, ref, summary),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, PiutangSummary summary) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tagihan: ${summary.namaPelanggan}', style: const TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(localDbProvider);
                for (var trx in summary.daftarTransaksi) {
                  await (db.update(db.transaksi)..where((t) => t.id.equals(trx.id))).write(
                    TransaksiCompanion(statusBayar: drift.Value('LUNAS')), // Fixed Drift Value
                  );
                }
                ref.invalidate(piutangListProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('LUNASKAN'),
            ),
          ],
        ),
      ),
    );
  }
}
