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
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Input Barang Baru',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangFormScreen())),
          ),
        ],
      ),
      // FIX: 2 FAB biar gak ketutup navigasi biru di screenshot kamu + bisa NEXT
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'nota',
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangMasukScreen())),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Masuk + HPP / Nota', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'baru',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangFormScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Barang Baru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 140), // biar gak ketutup FAB
            itemCount: daftarBarang.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final barang = daftarBarang[index];
              final satuanDisplay = barang.satuanTerkecil;
              final isLow = barang.stok <= barang.safetyStock;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isLow? Colors.orange.shade200 : const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BarangFormScreen(existing: barang))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text('SKU: ${barang.sku?? '-'} | Merek: ${barang.merek?? '-'} | Satuan: $satuanDisplay | Konversi: ${barang.konversi}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(height: 3),
                      Text('HPP Auto (MA): Rp ${barang.hppAverage.toStringAsFixed(0)} | Update: ${barang.updatedAt.day}/${barang.updatedAt.month}/${barang.updatedAt.year}', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: isLow? Colors.orange.shade50 : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Text('Stok: ${barang.stok}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isLow? Colors.orange.shade800 : const Color(0xFF0F172A))),
                      ),
                      const SizedBox(height: 4),
                      Text('Rp ${barang.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('Agen Rp ${barang.hargaAgen.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
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