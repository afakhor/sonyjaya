import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/perkakas_provider.dart';
import '../inventory/providers/inventory_provider.dart';
import '../../../core/database/local_database.dart'; // TAMBAHAN WAJIB

class PerkakasScreen extends ConsumerWidget {
  const PerkakasScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredBarangs = ref.watch(filteredPerkakasProvider);
    final filterState = ref.watch(perkakasFilterProvider);
    const primaryColor = Color(0xFF1E293B);
    final kategoriList = ['SEMUA', 'Bor', 'Gerinda', 'Kunci', 'Meteran', 'Tang'];
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Alat Perkakas Bangunan'), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => ref.read(perkakasFilterProvider.notifier).setSearchQuery(val),
                  decoration: InputDecoration(hintText: 'Cari nama perkakas atau merek (cth: Bosch, 【entity-Makita¦canonical_name=Makita】, Tekiro)...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0)),
                ),
                const SizedBox(height: 10),
                SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: kategoriList.length, itemBuilder: (context, index) {
                  final kat = kategoriList[index];
                  final isSelected = filterState.selectedCategory == kat;
                  return Padding(padding: const EdgeInsets.only(right: 8.0), child: ChoiceChip(label: Text(kat), selected: isSelected, onSelected: (selected) { ref.read(perkakasFilterProvider.notifier).setCategory(kat); }, selectedColor: primaryColor, labelStyle: TextStyle(color: isSelected? Colors.white : Colors.black87, fontWeight: FontWeight.bold)));
                })),
              ],
            ),
          ),
          Expanded(child: filteredBarangs.when(data: (items) {
            if (items.isEmpty) return const Center(child: Text('Tidak ada perkakas yang sesuai.', style: TextStyle(color: Colors.grey)));
            return GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: items.length, itemBuilder: (context, index) {
              final item = items[index];
              final isLowStock = item.stok <= item.safetyStock;
              return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(10.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: isLowStock? Colors.red.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(4)), child: Text(isLowStock? 'Stok Menipis' : 'Ready', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLowStock? Colors.red.shade800 : Colors.green.shade800))), Text('Stok: ${item.stok}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                const Spacer(),
                Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('SKU: ${item.sku?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Rp ${item.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14)),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, height: 32, child: OutlinedButton(style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: const BorderSide(color: primaryColor)), onPressed: () { _showPerkakasDetail(context, item); }, child: const Text('Detail', style: TextStyle(fontSize: 12, color: primaryColor)))),
              ])));
            });
          }, loading: () => const Center(child: CircularProgressIndicator()), error: (err, _) => Center(child: Text('Error: $err')))),
        ],
      ),
    );
  }

  void _showPerkakasDetail(BuildContext context, BarangData item) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (context) => Padding(padding: const EdgeInsets.all(20.0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(item.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Divider(),
      const SizedBox(height: 8),
      Text('SKU / Kode Barang: ${item.sku?? '-'}'),
      const SizedBox(height: 4),
      Text('Satuan Dasar: ${item.satuanTerkecil}'), // FIX
      const SizedBox(height: 4),
      Text('Sisa Stok Fisik: ${item.stok} (Safety Stock: ${item.safetyStock})'),
      const SizedBox(height: 4),
      Text('HPP Rata-rata: Rp ${item.hppAverage.toStringAsFixed(0)}'),
      const SizedBox(height: 4),
      Text('Harga Jual Ecer: Rp ${item.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white), onPressed: () => Navigator.pop(context), child: const Text('Tutup'))),
    ])));
  }
}