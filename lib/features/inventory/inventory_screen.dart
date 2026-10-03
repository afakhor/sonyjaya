import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/inventory_provider.dart';
import '../../../core/database/local_database.dart';
import 'barang_form_screen.dart';
import 'barang_masuk_screen.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Inventaris Barang'),
        actions: [
          IconButton(
            tooltip: 'Beli / Masuk + Update HPP',
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangMasukScreen())),
          ),
          IconButton(
            tooltip: 'Input Barang Baru',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangFormScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangMasukScreen())),
        label: const Text('Masuk + HPP'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
      body: inventoryAsync.when(
        data: (daftarBarang) {
          if (daftarBarang.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Stok barang kosong.'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangFormScreen())),
                  icon: const Icon(Icons.add),
                  label: const Text('Input Barang Perkakas Baru'),
                ),
              ]),
            );
          }
          return ListView.builder(
            itemCount: daftarBarang.length,
            itemBuilder: (context, index) {
              final barang = daftarBarang[index];
              final satuanDisplay = barang.satuanTerkecil; // FIX: pakai nama asli kolom
              return ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BarangFormScreen(existing: barang))),
                title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('SKU: ${barang.sku ?? '-'} | Merek: ${barang.merek ?? '-'} | Satuan: $satuanDisplay | Konversi: ${barang.konversi}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Stok: ${barang.stok}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp ${barang.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                    Text('HPP: Rp ${barang.hppAverage.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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