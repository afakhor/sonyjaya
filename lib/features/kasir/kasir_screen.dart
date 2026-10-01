import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/kasir_provider.dart';

class KasirScreen extends ConsumerWidget {
  const KasirScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    
    final double grandTotal = cartItems.fold(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Toko Bangunan (Sony Jaya iPOS 5)'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // BAGIAN KIRI: Daftar Barang / Katalog untuk dipilih kasir
          Expanded(
            flex: 6,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Katalog Barang Siap Jual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Expanded(
                  child: inventoryAsync.when(
                    data: (barangs) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: barangs.length,
                        itemBuilder: (context, index) {
                          final barang = barangs[index];
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
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('Stok: ${barang.stok} | Rp ${barang.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // BAGIAN KANAN: Keranjang Belanja & Tombol Pembayaran
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blueGrey.shade100,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Keranjang Belanja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Icon(Icons.shopping_cart),
                      ],
                    ),
                  ),
                  Expanded(
                    child: cartItems.isEmpty
                        ? const Center(child: Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return ListTile(
                                title: Text(item.barang.nama, maxLines: 1),
                                subtitle: Text('${item.qty} x Rp ${item.hargaJual.toStringAsFixed(0)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Rp ${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => ref.read(cartProvider.notifier).hapusItem(item.barang.id),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Rp ${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: cartItems.isEmpty
                              ? null
                              : () async {
                                  try {
                                    await ref.read(cartProvider.notifier).checkout();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Transaksi Berhasil! Stok terpotong aman.')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Gagal Transaksi (Proteksi Aktif)'),
                                          content: Text(e.toString().replaceAll('Exception: ', '')),
                                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: const Text('BAYAR / CHECKOUT SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
