import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/log_provider.dart'; 
// (Sesuaikan path import log_provider.dart jika berbeda)

final selectedItemLogProvider = StateProvider<int?>((ref) => null);

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pusat Log & Audit'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Stok'), 
              Tab(text: 'Jual'), 
              Tab(text: 'Beli'), 
              Tab(text: 'Opname'), 
              Tab(text: 'PO')
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LogStokTab(), 
            LogPenjualanTab(), 
            LogPembelianTab(), 
            LogOpnameTab(), 
            LogPoTab(),
          ],
        ),
      ),
    );
  }
}

// 1. Tab Log Stok
class LogStokTab extends ConsumerWidget {
  const LogStokTab({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stokAsync = ref.watch(logStokProvider);

    return stokAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('Belum ada catatan stok.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              title: Text('${item.tipe} (${item.qty})'),
            );
          },
        );
      },
    );
  }
}

// 2. Tab Log Penjualan
class LogPenjualanTab extends ConsumerWidget {
  const LogPenjualanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jualAsync = ref.watch(logPenjualanProvider);

    return jualAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('Belum ada catatan penjualan.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final p = list[index];
            return ListTile(
              title: Text('ID Transaksi: #${p.id} (Tipe: ${p.tipe})'),
              subtitle: Text('Qty: ${p.qtyPcs} Pcs | HPP: Rp ${p.hppSnapshot.toStringAsFixed(0)}'),
              trailing: Text('Laba: Rp ${p.laba.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

// 3. Tab Log Pembelian
class LogPembelianTab extends ConsumerWidget {
  const LogPembelianTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beliAsync = ref.watch(logPembelianProvider);

    return beliAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('Belum ada catatan pembelian.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final pb = list[index];
            return ListTile(
              title: Text('Supplier: ${pb.supplier ?? "Umum"}'),
              subtitle: Text('Qty Masuk: ${pb.qtyPcs} Pcs | Beli: Rp ${pb.hargaBeliPerPcs.toStringAsFixed(0)}'),
              trailing: Text(pb.tanggal.toLocal().toString().split('.')[0], style: const TextStyle(fontSize: 12)),
            );
          },
        );
      },
    );
  }
}

// 4. Tab Log Opname
class LogOpnameTab extends ConsumerWidget {
  const LogOpnameTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opnameAsync = ref.watch(logOpnameProvider);

    return opnameAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('Belum ada data Stock Opname.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final op = list[index];
            return ListTile(
              title: Text('Selisih Fisik: ${op.selisih}'),
              subtitle: Text('Sistem: ${op.stokSistem} | Fisik: ${op.stokFisik} | Ket: ${op.keterangan ?? "-"}'),
              trailing: Text(op.tanggal.toLocal().toString().split('.')[0], style: const TextStyle(fontSize: 12)),
            );
          },
        );
      },
    );
  }
}

// 5. Tab Log Purchase Order
class LogPoTab extends ConsumerWidget {
  const LogPoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poAsync = ref.watch(logPoProvider);

    return poAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('Belum ada data Purchase Order (PO).'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final po = list[index];
            return ListTile(
              leading: Icon(
                po.tipePo == 'VENDOR' ? Icons.local_shipping : Icons.shopping_bag,
                color: Colors.green,
              ),
              title: Text('No. PO: ${po.noPo} (${po.tipePo})'),
              subtitle: Text('Relasi: ${po.namaRelasi} | Total: Rp ${po.totalKeseluruhan.toStringAsFixed(0)}\nStatus: ${po.statusPo} (Auto Synced)'),
              isThreeLine: true,
              trailing: Text(
                po.tanggalBuat.toLocal().toString().split('.')[0],
                style: const TextStyle(fontSize: 11),
              ),
            );
          },
        );
      },
    );
  }
}
