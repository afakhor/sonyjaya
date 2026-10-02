import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// State untuk kata kunci pencarian & kategori perkakas yang dipilih
class PerkakasFilterState {
  final String searchQuery;
  final String selectedCategory;

  PerkakasFilterState({this.searchQuery = '', this.selectedCategory = 'SEMUA'});
}

class PerkakasFilterNotifier extends StateNotifier<PerkakasFilterState> {
  PerkakasFilterNotifier() : super(PerkakasFilterState());

  void setSearchQuery(String query) {
    state = PerkakasFilterState(searchQuery: queryPenyebab error tersebut ada pada `lib/features/log/log_screen.dart`. Pembaruan sintaks pada Drift mengharuskan penggunaan `drift.OrderingTerm(expression: ..., mode: drift.OrderingMode.desc)` alih-alih sintaks lama `drift.OrderingTerm.desc(...)`, namun di kode Anda tab Penjualan, Pembelian, Opname, dan PO masih menggunakan sintaks yang lama.

Berikut adalah kode lengkap `lib/features/log/log_screen.dart` yang sudah diperbaiki secara menyeluruh:

```dart
// lib/features/log/log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';

final selectedItemLogProvider = StateProvider<int?>((ref) => null);
final databaseProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

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
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<KartuStokData>>(
      stream: (db.select(db.kartuStok)..orderBy([(k) => drift.OrderingTerm(expression: k.tanggal, mode: drift.OrderingMode.desc)])).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return ListTile(title: Text('${item.tipe} (${item.qty})'));
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
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<PenjualanData>>(
      // FIXED: Menggunakan sintaks OrderingTerm yang benar
      stream: (db.select(db.penjualan)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
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
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<PembelianData>>(
      // FIXED: Menggunakan sintaks OrderingTerm yang benar
      stream: (db.select(db.pembelian)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
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
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<StockOpnameData>>(
      // FIXED: Menggunakan sintaks OrderingTerm yang benar
      stream: (db.select(db.stockOpname)..orderBy([(s) => drift.OrderingTerm(expression: s.tanggal, mode: drift.OrderingMode.desc)])).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
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
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<PurchaseOrderData>>(
      // FIXED: Menggunakan sintaks OrderingTerm yang benar
      stream: (db.select(db.purchaseOrders)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggalBuat, mode: drift.OrderingMode.desc)])).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
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
