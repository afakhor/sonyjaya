import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/log_provider.dart';

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(logDateRangeProvider);
    final search = ref.watch(logSearchQueryProvider);
    final selectedBarang = ref.watch(logSelectedBarangIdProvider);
    final labaAsync = ref.watch(labaPeriodeProvider);

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('CCTV Log & Audit'),
          bottom: const TabBar(isScrollable: true, tabs: [
            Tab(text: 'CCTV All'), Tab(text: 'Stok'), Tab(text: 'Beli'), Tab(text: 'Jual'), Tab(text: 'HPP'), Tab(text: 'Laba'), Tab(text: 'Opname/PO'),
          ]),
        ),
        body: Column(children: [
          // FILTER BAR - TANGGAL + BARANG + SEARCH = KOLABORASI LAPORAN
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Expanded(child: InkWell(onTap: () async {
                  final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDateRange: range.start!=null && range.end!=null? DateTimeRange(start: range.start!, end: range.end!) : null);
                  if (picked!= null) ref.read(logDateRangeProvider.notifier).setRange(picked.start, picked.end);
                }, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [const Icon(Icons.date_range_rounded, size: 18), const SizedBox(width: 6), Expanded(child: Text(range.start==null? 'Filter Periode' : '${range.start!.day}/${range.start!.month} - ${range.end!.day}/${range.end!.month}/${range.end!.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))] )))),
                const SizedBox(width: 8),
                if (range.start!= null) IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => ref.read(logDateRangeProvider.notifier).clear()),
                Consumer(builder: (context, ref, _) {
                  final barangsAsync = ref.watch(inventoryStreamProvider);
                  return barangsAsync.when(data: (list) => DropdownButton<int?>(value: selectedBarang, hint: const Text('Semua Barang', style: TextStyle(fontSize: 11)), items: [const DropdownMenuItem(value: null, child: Text('Semua')),...list.map((b) => DropdownMenuItem(value: b.id, child: Text(b.nama, style: const TextStyle(fontSize: 11))))], onChanged: (v) => ref.read(logSelectedBarangIdProvider.notifier).set(v)), loading: () => const SizedBox(), error: (_,__)=>const SizedBox());
                }),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(onChanged: (v) => ref.read(logSearchQueryProvider.notifier).set(v), decoration: const InputDecoration(isDense: true, hintText: 'Cari nota, supplier, tipe...', prefixIcon: Icon(Icons.search, size: 18), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 8)))),
                const SizedBox(width: 8),
                labaAsync.when(data: (laba) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: laba>=0? const Color(0xFFF0FDF4): const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)), child: Text('Laba: Rp ${laba.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: laba>=0? Colors.green: Colors.red))), loading: ()=>const SizedBox(), error: (_,__)=>const SizedBox()),
              ]),
            ]),
          ),
          const Expanded(child: TabBarView(children: [
            CctvTab(), LogStokTab(), LogPembelianTab(), LogPenjualanTab(), HppMovementTab(), LabaTab(), LogOpnamePoTab(),
          ])),
        ]),
      ),
    );
  }
}

class CctvTab extends ConsumerWidget { const CctvTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) {
  final cctv = ref.watch(cctvLogProvider);
  return cctv.when(data: (list) {
    if (list.isEmpty) return const Center(child: Text('Belum ada history CCTV'));
    return ListView.separated(padding: const EdgeInsets.all(12), itemCount: list.length, separatorBuilder: (_,__)=>const SizedBox(height: 6), itemBuilder: (c,i){
      final e = list[i]; final DateTime tgl = e['tanggal']; final String tipe = e['tipe']; Color col = Colors.grey; IconData icon = Icons.circle;
      if (tipe.contains('MASUK')||tipe=='PEMBELIAN') {col=Colors.green; icon=Icons.add_box_rounded;} else if (tipe.contains('KELUAR')||tipe=='PENJUALAN') {col=Colors.red; icon=Icons.outbox_rounded;} else if (tipe.contains('KOREKSI_HPP')) {col=Colors.orange; icon=Icons.price_change_rounded;} else if (tipe.contains('OPNAME')) {col=Colors.blue; icon=Icons.inventory_rounded;}
      return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))), child: ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: col, size: 18)), title: Text('${tipe} | Qty ${e['qty']} | Stok Akhir ${e['stokAkhir']??'-'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), subtitle: Text('${tgl.day}/${tgl.month}/${tgl.year} ${tgl.hour}:${tgl.minute.toString().padLeft(2,'0')} | Ref: ${e['ref']??'-'} | HPP: Rp ${(e['hpp']??0).toStringAsFixed(0)} ${e['laba']!=null? '| Laba Rp ${e['laba'].toStringAsFixed(0)}':''}', style: const TextStyle(fontSize: 11))));
    });
  }, loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,_ )=>Center(child: Text('Error $e')));
}}

class LogStokTab extends ConsumerWidget { const LogStokTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final data = ref.watch(logStokProvider); return data.when(data: (list)=>ListView.builder(padding: const EdgeInsets.all(12), itemCount: list.length, itemBuilder: (_,i){ final k=list[i]; return Container(margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))), child: ListTile(dense: true, title: Text('${k.tipe} ${k.qty} | Akhir ${k.stokAkhir} | HPP Rp ${k.hargaBeliSaatItu?.toStringAsFixed(0)??'-'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), subtitle: Text('${k.tanggal.day}/${k.tanggal.month}/${k.tanggal.year} | ${k.refId??'-'}', style: const TextStyle(fontSize: 11)))); }, ), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,_)=>Center(child: Text('$e'))); }}
class LogPembelianTab extends ConsumerWidget { const LogPembelianTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final data = ref.watch(logPembelianProvider); return data.when(data: (list)=>ListView.builder(padding: const EdgeInsets.all(12), itemCount: list.length, itemBuilder: (_,i){ final p=list[i]; return Container(margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: ListTile(title: Text('Beli ${p.qtyPcs} Pcs @ Rp ${p.hargaBeliPerPcs.toStringAsFixed(0)} | ${p.supplier??'Umum'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), subtitle: Text('${p.tanggal.day}/${p.tanggal.month}/${p.tanggal.year}', style: const TextStyle(fontSize: 11)))); }, ), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,_)=>Center(child: Text('$e'))); }}
class LogPenjualanTab extends ConsumerWidget { const LogPenjualanTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final data = ref.watch(logPenjualanProvider); return data.when(data: (list)=>ListView.builder(padding: const EdgeInsets.all(12), itemCount: list.length, itemBuilder: (_,i){ final p=list[i]; return Container(margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: ListTile(title: Text('Jual ${p.qtyPcs} Pcs | HPP ${p.hppSnapshot.toStringAsFixed(0)} | ${p.tipe}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), trailing: Text('Laba Rp ${p.laba.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: p.laba>=0? Colors.green: Colors.red)))) ; }, ), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,_)=>Center(child: Text('$e'))); }}
class HppMovementTab extends ConsumerWidget { const HppMovementTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final data = ref.watch(logStokProvider); return data.when(data: (list){ final filtered = list.where((e)=> e.tipe=='MASUK' || e.tipe=='KOREKSI_HPP').toList(); return ListView.builder(padding: const EdgeInsets.all(12), itemCount: filtered.length, itemBuilder: (_,i){ final k=filtered[i]; return Container(margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: ListTile(title: Text('${k.tipe} | Harga Saat Itu Rp ${k.hargaBeliSaatItu?.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), subtitle: Text('${k.tanggal.day}/${k.tanggal.month}/${k.tanggal.year} | Stok Akhir ${k.stokAkhir}', style: const TextStyle(fontSize: 11)))); }); }, loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,_)=>Center(child: Text('$e'))); }}
class LabaTab extends ConsumerWidget { const LabaTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final data = ref.watch(logPenjualanProvider); final laba = ref.watch(labaPeriodeProvider); return Column(children: [laba.when(data: (v)=>Container(width: double.infinity, color: Colors.white, padding: const EdgeInsets.all(16), child: Text('Total Laba Periode: Rp ${v.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w800, color: v>=0? Colors.green: Colors.red))), loading: ()=>const SizedBox(), error: (_,__)=>const SizedBox()), Expanded(child: data.when(data: (list)=>ListView.builder(padding: const EdgeInsets.all(12), itemCount: list.length, itemBuilder: (_,i){ final p=list[i]; return ListTile(title: Text('Laba Rp ${p.laba.toStringAsFixed(0)} | Jual ${p.qtyPcs} Pcs'), subtitle: Text('${p.tanggal.day}/${p.tanggal.month}/${p.tanggal.year} | HPP ${p.hppSnapshot.toStringAsFixed(0)}')); }, ), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,_)=>Center(child: Text('$e'))))]); }}
class LogOpnamePoTab extends ConsumerWidget { const LogOpnamePoTab({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final op = ref.watch(logOpnameProvider); final po = ref.watch(logPoProvider); return ListView(children: [const Padding(padding: EdgeInsets.all(12), child: Text('Stock Opname', style: TextStyle(fontWeight: FontWeight.bold))), op.when(data: (list)=>Column(children: list.map((e)=>ListTile(dense: true, title: Text('Selisih ${e.selisih} | Sistem ${e.stokSistem} -> Fisik ${e.stokFisik}'), subtitle: Text('${e.tanggal.day}/${e.tanggal.month} | ${e.keterangan??'-'}'))).toList()), loading: ()=>const CircularProgressIndicator(), error: (_,__)=>const SizedBox()), const Divider(), const Padding(padding: EdgeInsets.all(12), child: Text('PO', style: TextStyle(fontWeight: FontWeight.bold))), po.when(data: (list)=>Column(children: list.map((p)=>ListTile(dense: true, title: Text('${p.noPo} ${p.tipePo} ${p.namaRelasi}'), subtitle: Text('Rp ${p.totalKeseluruhan.toStringAsFixed(0)} | ${p.statusPo}'))).toList()), loading: ()=>const CircularProgressIndicator(), error: (_,__)=>const SizedBox())]); }}