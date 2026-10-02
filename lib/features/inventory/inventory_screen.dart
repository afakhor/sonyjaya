import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/inventory_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);

    return Scaffold(
      app: AppBar(
        title: const Text('Manajemen Gudang Perkakas'),
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada inventaris barang.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final barang = items[index];
              final isKritis = barang.stok <= barang.safetyStock;

              return Card(
                color: isKritis ? Colors.red.withOpacity(0.15) : null,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('SKU: ${barang.sku ?? "-"} | HPP: Rp ${barang.hppAverage} | Safety Stock: ${barang.safetyStock}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Stok: ${barang.stok}', style: TextStyle(fontWeight: FontWeight.bold, color: isKritis ? Colors.redAccent : Colors.green)),
                      if (isKritis)
                        const Text('STOK KRITIS!', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
