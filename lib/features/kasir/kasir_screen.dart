import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/kasir_provider.dart';

class KasirScreen extends ConsumerWidget {
  const KasirScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final inventoryAsync = ref.watch(inventoryStreamProvider);

    double totalBelanja = cartItems.fold(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      app: AppBar(
        title: const Text('Sony Jaya - Kasir Pintar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
          )
        ],
      ),
      body: Row(
        children: [
          // Sisi Kiri: Daftar Barang / Katalog Toko Perkakas
          Expanded(
            flex: 3,
            child: inventoryAsync.when(
              data: (daftarBarang) {
                if (daftarBarang.isEmpty) {
                  return const Center(child: Text('Belum ada data barang perkakas.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: daftarBarang.length,
                  itemBuilder: (context, index) {
                    final barang = daftarBarang[index];
                    return InkWell(
                      onTap: () {
                        try {
                          ref.read(cartProvider.notifier).tambahItem(barang);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                          );
                        }
                      },
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Stok: ${barang.stok} | Rp ${barang.hargaEcer}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          const VerticalDivider(width: 1),
          // Sisi Kanan: Keranjang & Checkout
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Keranjang Belanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.barang.nama),
                        subtitle: Text('${item.qty} x Rp ${item.hargaJual}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => ref.read(cartProvider.notifier).hapusItem(item.barang.id),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp $totalBelanja', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                        ).wrap(
                          ElevatedButton(
                            onPressed: cartItems.isEmpty ? null : () async {
                              try {
                                await ref.read(cartProvider.notifier).checkout();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transaksi Berhasil Disimpan & Cache Disinkronkan!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal Checkout: $e')),
                                );
                              }
                            },
                            child: const Text('PROSES PEMBAYARAN'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on ButtonStyle {
  Widget wrap(Widget child) {
    return Builder(
      builder: (context) => ElevatedButton(
        style: this,
        onPressed: (child as ElevatedButton).onPressed,
        child: child.child,
      ),
    );
  }
}
