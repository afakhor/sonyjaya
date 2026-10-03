import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'log_screen.g.dart';

@riverpod
class SelectedItemLog extends _$SelectedItemLog {
  @override
  int? build() => null;
  void set(int? v) => state = v;
}

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(length: 5, child: Scaffold(appBar: AppBar(title: const Text('Pusat Log & Audit'), bottom: const TabBar(isScrollable: true, tabs: [Tab(text: 'Stok'), Tab(text: 'Jual'), Tab(text: 'Beli'), Tab(text: 'Opname'), Tab(text: 'PO')])), body: const TabBarView(children: [LogStokTab(), LogPenjualanTab(), LogPembelianTab(), LogOpnameTab(), LogPoTab()])));
  }
}

class LogStokTab extends ConsumerWidget {
  const LogStokTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(localDbProvider);
    return StreamBuilder<List<KartuStokData>>(stream: (db.select(db.kartuStok)..orderBy([(k) => drift.OrderingTerm(expression: k.tanggal, mode: drift.OrderingMode.desc)])).watch(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); return ListView.builder(itemCount: snapshot.data!.length, itemBuilder: (context, index) { final item = snapshot.data![index]; return ListTile(title: Text('${item.tipe} (${item.qty})')); }); });
  }
}
class LogPenjualanTab extends ConsumerWidget {
  const LogPenjualanTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(localDbProvider);
    return StreamBuilder<List<PenjualanData>>(stream: (db.select(db.penjualan)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])).watch(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final list = snapshot.data!; if (list.isEmpty) return const Center(child: Text('Belum ada catatan penjualan.')); return ListView.builder(itemCount: list.length, itemBuilder: (context, index) { final p = list[index]; return ListTile(title: Text('ID Transaksi: #${p.id} (Tipe: ${p.tipe})'), subtitle: Text('Qty: ${p.qtyPcs} Pcs | HPP: Rp ${p.hppSnapshot.toStringAsFixed(0)}'), trailing: Text('Laba: Rp ${p.laba.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))); }); });
  }
}
class LogPembelianTab extends ConsumerWidget {
  const LogPembelianTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(localDbProvider);
    return StreamBuilder<List<PembelianData>>(stream: (db.select(db.pembelian)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggal, mode: drift.OrderingMode.desc)])).watch(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final list = snapshot.data!; if (list.isEmpty) return const Center(child: Text('Belum ada catatan pembelian.')); return ListView.builder(itemCount: list.length, itemBuilder: (context, index) { final pb = list[index]; return ListTile(title: Text('Supplier: ${pb.supplier?? "Umum"}'), subtitle: Text('Qty Masuk: ${pb.qtyPcs} Pcs | Beli: Rp ${pb.hargaBeliPerPcs.toStringAsFixed(0)}'), trailing: Text(pb.tanggal.toLocal().toString().split('.')[0], style: const TextStyle(fontSize: 12))); }); });
  }
}
class LogOpnameTab extends ConsumerWidget {
  const LogOpnameTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(localDbProvider);
    return StreamBuilder<List<StockOpnameData>>(stream: (db.select(db.stockOpname)..orderBy([(s) => drift.OrderingTerm(expression: s.tanggal, mode: drift.OrderingMode.desc)])).watch(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final list = snapshot.data!; if (list.isEmpty) return const Center(child: Text('Belum ada data Stock Opname.')); return ListView.builder(itemCount: list.length, itemBuilder: (context, index) { final op = list[index]; return ListTile(title: Text('Selisih Fisik: ${op.selisih}'), subtitle: Text('Sistem: ${op.stokSistem} | Fisik: ${op.stokFisik} | Ket: ${op.keterangan?? "-"}'), trailing: Text(op.tanggal.toLocal().toString().split('.')[0], style: const TextStyle(fontSize: 12))); }); });
  }
}
class LogPoTab extends ConsumerWidget {
  const LogPoTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(localDbProvider);
    return StreamBuilder<List<PurchaseOrdersData>>(stream: (db.select(db.purchaseOrders)..orderBy([(p) => drift.OrderingTerm(expression: p.tanggalPo, mode: drift.OrderingMode.desc)])).watch(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final list = snapshot.data!; if (list.isEmpty) return const Center(child: Text('Belum ada data Purchase Order (PO).')); return ListView.builder(itemCount: list.length, itemBuilder: (context, index) { final po = list[index]; return ListTile(leading: Icon(po.tipePo == 'VENDOR'? Icons.local_shipping : Icons.shopping_bag, color: Colors.green), title: Text('No. PO: ${po.noPo} (${po.tipePo})'), subtitle: Text('Relasi: ${po.namaRelasi} | Total: Rp ${po.totalKeseluruhan.toStringAsFixed(0)}\nStatus: ${po.statusPo} (Auto Synced)'), isThreeLine: true, trailing: Text(po.tanggalPo.toLocal().toString().split('.')[0], style: const TextStyle(fontSize: 11))); }); });
  }
}