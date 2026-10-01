import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auto_po_provider.dart';

class AutoPoNotificationWidget extends ConsumerWidget {
  const AutoPoNotificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF1E293B); // Contoh warna tema gelap/modern
    final draftPoAsync = ref.watch(autoPoDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Auto-PO Stok'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: draftPoAsync.when(
        data: (items) {
          if (items.isEmpty) {
            const emptyMessage = 'Stok aman! Tidak ada barang di bawah safety stock.';
            return const Center(child: Text(emptyMessage));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Sisa Stok: ${item['stokSisa']} | Safety Stock: ${item['safetyStock']}'),
                  trailing: Chip(
                    label: Text('Order: ${item['saranQtyOrder']} Pcs'),
                    backgroundColor: Colors.orange.shade100,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err')),
      ),
    );
  }
}
