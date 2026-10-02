lib/features/inventory/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/inventory_provider.dart'; // Sesuaikan path import provider Anda

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok Barang & Gudang'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama barang atau SKU...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: inventoryAsync.when(
        data: (barangs) {
          // Filter pencarian lokal berdasarkan nama atau SKU
          final filteredList = barangs.where((b) {
            final nama = b.nama.toLowerCase();
            final sku = (b.sku ?? '').toLowerCase();
            return nama.contains(_searchQuery) || sku.contains(_searchQuery);
          }).toList();

          if (filteredList.isEmpty) {
            return const Center(
              child: Text('Tidak ada data barang ditemukan.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: filteredList.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final barang = filteredList[index];
              final isLowStock = barang.stok <= barang.safetyStock;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: isLowStock ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Icon(
                      isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2,
                      color: isLowStock ? Colors.red : Colors.blue.shade800,
                    ),
                  ),
                  title: Text(
                    barang.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('SKU: ${barang.sku ?? '-'} | Satuan: ${barang.satuanDasar}'),
                      const SizedBox(height: 2),
                      Text(
                        'HPP Rata-rata: Rp ${barang.hppAverage.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Stok: ${barang.stok}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isLowStock ? Colors.red : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Safety: ${barang.safetyStock}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Opsi: Munculkan dialog detail / opsi transaksi cepat
                    _showActionDialog(context, ref, barang.id, barang.nama);
                  },
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

  void _showActionDialog(BuildContext context, WidgetRef ref, int barangId, String namaBarang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aksi Cepat: $namaBarang'),
        content: const Text('Pilih jenis transaksi untuk barang ini:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showTransaksiDialog(context, ref, barangId, 'BELI');
            },
            child: const Text('Tambah Stok (Beli)', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showTransaksiDialog(context, ref, barangId, 'JUAL');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
            child: const Text('Kurangi Stok (Jual)'),
          ),
        ],
      ),
    );
  }

  void _showTransaksiDialog(BuildContext context, WidgetRef ref, int barangId, String tipe) {
    final qtyController = TextEditingController();
    final hargaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tipe == 'BELI' ? 'Input Pembelian Stok' : 'Input Penjualan Cepat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Qty) Pcs'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tipe == 'BELI' ? 'Harga Beli Satuan' : 'Harga Jual Satuan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text) ?? 0;
              final harga = double.tryParse(hargaController.text) ?? 0.0;

              if (qty > 0 && harga > 0) {
                final controller = ref.read(inventoryControllerProvider);
                if (tipe == 'BELI') {
                  await controller.beli(barangId: barangId, qty: qty, harga: harga);
                } else {
                  await controller.jual(barangId: barangId, qty: qty, hargaJual: harga);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
