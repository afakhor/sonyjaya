import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cache/isar_service.dart';
import '../../core/cache/models/fast_stock_cache.dart';

class AutoPoScreen extends StatelessWidget {
  const AutoPoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app: AppBar(
        title: const Text('Auto-PO & Fast Moving Dashboard'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Daftar Barang Perlu Reorder (Isar Real-time Cache)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FastStockCache>>(
              stream: IsarService.watchPerluReorder(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final listReorder = snapshot.data!;
                if (listReorder.isEmpty) {
                  return const Center(child: Text('Semua stok aman, tidak ada PO otomatis.'));
                }

                return ListView.builder(
                  itemCount: listReorder.length,
                  itemBuilder: (context, index) {
                    final item = listReorder[index];
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.amber),
                      title: Text(item.nama),
                      subtitle: Text('Stok Sisa: ${item.stok} | Safety: ${item.safetyStock}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Aksi Buat PO Otomatis ke Supplier
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PO Otomatis dibuat untuk ${item.nama}!')),
                          );
                        },
                        child: const Text('Generate PO'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
