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
