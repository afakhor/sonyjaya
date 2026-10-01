import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';

final selectedItemLogProvider = StateProvider<int?>((ref) => null);

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF1E293B);

    return DefaultTabController(
      length: 4,
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
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LogStokTab(),
            LogPenjualanTab(),
            LogPembelianTab(),
            LogOpnameTab(),
          ],
        ),
      ),
    );
  }
}

// 1. Tab Log Kartu Stok (Bisa Filter Berdasarkan Barang)
class LogStokTab extends ConsumerWidget {
  const LogStokTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = LocalDatabase();
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
                    subtitle: Text('Sisa Stok Akhir: ${item.stokAkhir} | Tgl: ${item.tanggal}'),
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
class LogPenjualanTab extends StatelessWidget {
  const LogPenjualanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = LocalDatabase();
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
              subtitle: Text('Qty: ${p.qtyPcs} | HPP Snapshot: Rp ${p.hppSnapshot}'),
              trailing: Text('Laba: Rp ${p.laba}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

// 3. Tab Log Pembelian
class LogPembelianTab extends StatelessWidget {
  const LogPembelianTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = LocalDatabase();
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
              subtitle: Text('Qty Masuk: ${pb.qtyPcs} Pcs | Harga Beli: Rp ${pb.hargaBeliPerPcs}'),
              trailing: Text(pb.tanggal.toLocal().toString().split('.')[0], style: const TextStyle(fontSize: 12)),
            );
          },
        );
      },
    );
  }
}

// 4. Tab Log Opname
class LogOpnameTab extends StatelessWidget {
  const LogOpnameTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = LocalDatabase();
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
