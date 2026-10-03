import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/inventory_provider.dart';
import '../../../core/database/local_database.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Inventaris Barang')),
      body: inventoryAsync.when(
        data: (daftarBarang) {
          if (daftarBarang.isEmpty) return const Center(child: Text('Stok barang kosong.'));
          return ListView.builder(
            itemCount: daftarBarang.length,
            itemBuilder: (context, index) {
              final barang = daftarBarang[index];
              final satuanDisplay = barang.satuanTerkecil; // FIX: pakai nama asli
              return ListTile(
                title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('SKU: ${barang.sku?? '-'} | Satuan: $satuanDisplay'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Stok: ${barang.stok}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp ${barang.hargaEcer}'),
                  ],
                ),
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