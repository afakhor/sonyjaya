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
        title: const Text('Daftar Hutang Supplier'),
      ),
      body: hutangAsync.when(
        data: (listHutang) {
          if (listHutang.isEmpty) {
            return const Center(child: Text('Tidak ada hutang supplier.'));
          }
          return ListView.builder(
            itemCount: listHutang.length,
            itemBuilder: (context, index) {
              final hutang = listHutang[index];
              return ExpansionTile(
                title: Text(
                  hutang.namaSupplier,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${hutang.jumlahPo} PO Belum Lunas'),
                trailing: Text(
                  'Rp ${hutang.totalHutang.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                children: hutang.daftarPo.map((po) {
                  final tgl = po.tanggalPo.toLocal().toString().split('.')[0];
                  return ListTile(
                    dense: true,
                    title: Text('PO #${po.id} - $tgl'),
                    subtitle: Text('Status: ${po.statusBayar}'),
                    trailing: Text(
                      'Rp ${po.totalKeseluruhan.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
