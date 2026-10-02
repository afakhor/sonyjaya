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
      ),
      body: hutangAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('Tidak ada hutang vendor aktif.'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ExpansionTile(
                title: Text(group.namaSupplier),
                subtitle: Text('Total: Rp ${group.totalHutang.toStringAsFixed(0)}'),
                children: group.daftarPo.map((po) {
                  return ListTile(
                    title: Text('PO #${po.noPo}'),
                    subtitle: Text('Tanggal: ${po.tanggalPo.toLocal().toString().split(' ')[0]}'),
                    trailing: Text('Rp ${po.totalKeseluruhan.toStringAsFixed(0)}'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
