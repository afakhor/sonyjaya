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
    const primaryColor = Color(0xFF1E293B);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pusat Log & Audit Toko'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: 'Log Keluar/Masuk Stok'),
              Tab(text: 'Log Penjualan'),
              Tab(text: 'Log Pembelian'),
              Tab(text: 'Log Opname'),
              Tab(text: 'Log Purchase Order (PO)'),
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

// 1. Tab Log Kartu Stok
class LogStokTab extends ConsumerWidget {
  const LogStokTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final selectedBarangId = ref.watch(selectedItemLogProvider);

    return Column(
      children: [
        FutureBuilder<List<BarangData>>(
          future: db.select(db.barang).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final listBarang = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<int?>(
                value: selectedBarangId,
                decoration: const InputDecoration(labelText: 'Filter Berdasarkan Item Barang', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Barang')),
                  ...listBarang.map((b) => DropdownMenuItem(value: b.id, child: Text(b.nama))),
                ],
                onChanged: (val) => ref.read(selectedItemLogProvider.notifier).state = val,
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<List<KartuStokData>>(
            stream: (() {
              var query = db.select(db.kartuStok);
              if (selectedBarangId != null) {
                query.where((k) => k.barangId.equals(selectedBarangId));
              }
              return (query..orderBy([(k) => drift.OrderingTerm.desc(k.tanggal)])).watch();
            })(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final data = snapshot.data!;
              if (data.isEmpty) return const Center(child: Text('Belum ada riwayat mutasi stok.'));
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  final isMasuk = item.qty > 0;
                  return ListTile(
                    leading: Icon(isMasuk ? Icons.arrow_downward : Icons.arrow_upward, color: isMasuk ? Colors.green : Colors.red),
                    title: Text('Mutasi: ${item.tipe} (${item.qty > 0 ? "+${item.qty}" : item.qty})'),
                    subtitle: Text('Sisa Stok Akhir: ${item.stokAkhir} | Tgl: ${item.tanggal.toLocal().toString().split('.')[0]}'),
                  );
                },
              );
            },
          ),
        ),
      ],
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
      stream: (db.select(db.penjualan)..orderBy([(p) => drift.OrderingTerm.desc(p.tanggal)])).watch(),
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
      stream: (db.select(db.pembelian)..orderBy([(p) => drift.OrderingTerm.desc(p.tanggal)])).watch(),
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
      stream: (db.select(db.stockOpname)..orderBy([(s) => drift.OrderingTerm.desc(s.tanggal)])).watch(),
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

// 5. Tab Log Purchase Order (Otomatis Selesai)
class LogPoTab extends ConsumerWidget {
  const LogPoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<PurchaseOrderData>>(
      stream: (db.select(db.purchaseOrders)..orderBy([(p) => drift.OrderingTerm.desc(p.tanggalBuat)])).watch(),
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
