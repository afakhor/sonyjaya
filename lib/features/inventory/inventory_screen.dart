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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manajemen Inventaris Barang'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Beli Masuk + HPP',
            icon: const Icon(Icons.add_shopping_cart_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangMasukScreen())),
          ),
          IconButton(
            tooltip: 'Input Baru',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangFormScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangMasukScreen())),
        label: const Text('Masuk + HPP', style: TextStyle(fontWeight: FontWeight.w700)),
        icon: const Icon(Icons.add_shopping_cart_rounded),
      ),
      body: inventoryAsync.when(
        data: (daftarBarang) {
          if (daftarBarang.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Stok barang kosong.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangFormScreen())),
                    icon: const Icon(Icons.add),
                    label: const Text('Input Barang Perkakas Baru'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: daftarBarang.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final barang = daftarBarang[index];
              final satuanDisplay = barang.satuanTerkecil; // FIX: pakai nama asli kolom
              final isLow = barang.stok <= barang.safetyStock;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isLow? Colors.orange.shade200 : const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BarangFormScreen(existing: barang))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('SKU: ${barang.sku?? '-'} | Merek: ${barang.merek?? '-'} | Satuan: $satuanDisplay',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text('HPP: Rp ${barang.hppAverage.toStringAsFixed(0)} | Konversi: ${barang.konversi}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLow? Colors.orange.shade50 : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Stok: ${barang.stok}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isLow? Colors.orange.shade800 : const Color(0xFF0F172A))),
                      ),
                      const SizedBox(height: 4),
                      Text('Rp ${barang.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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