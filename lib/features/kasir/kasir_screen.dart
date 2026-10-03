import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/kasir_provider.dart';
import 'services/receipt_service.dart';

class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});
  @override ConsumerState<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  final Map<int, TextEditingController> _qtyControllers = {};
  final GlobalKey _strukKey = GlobalKey();

  @override
  void dispose() {
    for (var c in _qtyControllers.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _prosesCheckout() async {
    if (ref.read(cartProvider).isEmpty) return;
    final cart = ref.read(cartProvider);
    final total = cart.fold<double>(0, (s, e) => s + e.subtotal);
    final itemsForStruk = cart.map((e) => {
      'nama': e.barang.nama,
      'qty': e.qty,
      'harga': e.hargaJual.toStringAsFixed(0),
      'subtotal': e.subtotal.toStringAsFixed(0)
    }).toList();
    final nota = 'NOTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final tgl = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2,'0')}';

    try {
      await ref.read(cartProvider.notifier).checkout();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      return;
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16,16,16,32),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 12),
              const Text('Transaksi Berhasil!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF10B981))),
              const SizedBox(height: 12),
              RepaintBoundary(
                key: _strukKey,
                child: ReceiptService.buildStrukWidget(items: itemsForStruk, grandTotal: total, tanggal: tgl, nota: nota),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.print_rounded, size: 18), label: const Text('PRINT', style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () async {
                  try {
                    final file = await ReceiptService.captureWidgetToJpg(_strukKey);
                    final bytes = await file.readAsBytes();
                    await Printing.layoutPdf(onLayout: (format) async => bytes);
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print gagal: $e')));
                  }
                })),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.share_rounded, size: 18), label: const Text('SHARE JPG', style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), side: const BorderSide(color: Color(0xFF0F172A)), padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () async {
                  final file = await ReceiptService.captureWidgetToJpg(_strukKey);
                  await Share.shareXFiles([XFile(file.path)], text: 'Struk Belanja $nota - Total Rp ${total.toStringAsFixed(0)}');
                })),
              ]),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.chat_rounded, size: 18), label: const Text('SHARE WA (.JPG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () async {
                final file = await ReceiptService.captureWidgetToJpg(_strukKey);
                await Share.shareXFiles([XFile(file.path, mimeType: 'image/jpeg')], text: 'Halo, ini struk belanja Sony Jaya Perkakas\n$nota\nTotal Rp ${total.toStringAsFixed(0)}\nTerima kasih 🙏');
              })),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    final filter = ref.watch(kasirFilterProvider);
    final totalBelanja = cartItems.fold<double>(0, (sum, e) => sum + e.subtotal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: const Text('Sony Jaya - Kasir Pintar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), actions: [IconButton(icon: const Icon(Icons.delete_sweep_rounded), onPressed: () => ref.read(cartProvider.notifier).clearCart())]),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(12,8,12,8), child: Column(children: [
          TextField(onChanged: (v) => ref.read(kasirFilterProvider.notifier).setSearch(v), decoration: InputDecoration(isDense: true, hintText: 'Cari nama / SKU / merek...', prefixIcon: const Icon(Icons.search, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 10))),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            _chip('Semua', filter.kategori==FilterKategoriHarga.semua, ()=>ref.read(kasirFilterProvider.notifier).setKategori(FilterKategoriHarga.semua)),
            _chip('Ecer', filter.kategori==FilterKategoriHarga.ecer, ()=>ref.read(kasirFilterProvider.notifier).setKategori(FilterKategoriHarga.ecer)),
            _chip('Agen', filter.kategori==FilterKategoriHarga.agen, ()=>ref.read(kasirFilterProvider.notifier).setKategori(FilterKategoriHarga.agen)),
            _chip('Margin Tinggi', filter.kategori==FilterKategoriHarga.marginTinggi, ()=>ref.read(kasirFilterProvider.notifier).setKategori(FilterKategoriHarga.marginTinggi)),
          ])),
        ])),
        Expanded(child: Row(children: [
          Expanded(flex: 5, child: inventoryAsync.when(
            data: (list) {
              var filtered = list.where((b)=> b.nama.toLowerCase().contains(filter.search.toLowerCase()) || (b.sku??'').toLowerCase().contains(filter.search.toLowerCase())).toList();
              if (filter.kategori==FilterKategoriHarga.marginTinggi) filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer - b.hppAverage)/b.hppAverage*100)>=30).toList();
              if (filtered.isEmpty) return const Center(child: Text('Tidak ada barang'));
              return GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: filtered.length, itemBuilder: (_,i){
                final barang = filtered[i];
                _qtyControllers.putIfAbsent(barang.id, ()=>TextEditingController(text: '1'));
                final marginEcer = barang.hppAverage==0?0: (barang.hargaEcer - barang.hppAverage)/barang.hppAverage*100;
                final marginAgen = barang.hppAverage==0?0: (barang.hargaAgen - barang.hppAverage)/barang.hppAverage*100;
                return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(barang.nama, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: barang.stok<=barang.safetyStock? Colors.red.shade50: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), child: Text('Stok ${barang.stok}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: barang.stok<=barang.safetyStock? Colors.red: Colors.black)))]),
                  const SizedBox(height: 4),
                  Text('SKU ${barang.sku??'-'} | ${barang.merek??'-'}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text('Ecer: Rp ${barang.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Text('${marginEcer.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: marginEcer>=20? Colors.green: Colors.orange, fontWeight: FontWeight.bold))]),
                    Row(children: [Expanded(child: Text('Agen: Rp ${barang.hargaAgen.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700))), Text('${marginAgen.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: marginAgen>=10? Colors.green: Colors.orange, fontWeight: FontWeight.bold))]),
                    Text('HPP: Rp ${barang.hppAverage.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ])),
                  const SizedBox(height: 6),
                  Row(children: [
                    SizedBox(width: 48, child: TextField(controller: _qtyControllers[barang.id], keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
                    const SizedBox(width: 4),
                    Expanded(child: ElevatedButton(onPressed: (){ try{ final qty=int.tryParse(_qtyControllers[barang.id]!.text)??1; ref.read(cartProvider.notifier).tambahItem(barang, qty: qty, tipeHarga: TipeHarga.ecer); }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Ecer', style: TextStyle(fontSize: 10)))),
                    const SizedBox(width: 4),
                    Expanded(child: ElevatedButton(onPressed: (){ try{ final qty=int.tryParse(_qtyControllers[barang.id]!.text)??1; ref.read(cartProvider.notifier).tambahItem(barang, qty: qty, tipeHarga: TipeHarga.agen); }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), side: const BorderSide(color: Color(0xFF0F172A)), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Agen', style: TextStyle(fontSize: 10)))),
                  ]),
                ]));
              });
            },
            loading: ()=>const Center(child: CircularProgressIndicator()),
            error: (e,_)=>Center(child: Text('$e')),
          )),
          const VerticalDivider(width: 1),
          Expanded(flex: 3, child: Container(color: Colors.white, child: Column(children: [
            Container(padding: const EdgeInsets.all(12), color: const Color(0xFFF8FAFC), child: Row(children: [const Icon(Icons.receipt_long_rounded, size: 18), const SizedBox(width: 6), const Text('Keranjang Belanja', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), const Spacer(), Text('${cartItems.length} item', style: const TextStyle(fontSize: 11, color: Colors.grey))])),
            Expanded(child: cartItems.isEmpty? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 32, color: Colors.grey.shade300), const SizedBox(height: 8), Text('Keranjang kosong', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])) : ListView.separated(padding: const EdgeInsets.all(10), itemCount: cartItems.length, separatorBuilder: (_,__)=>const Divider(height: 1), itemBuilder: (_,i){
              final item=cartItems[i];
              return Container(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(item.barang.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)), IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: ()=>ref.read(cartProvider.notifier).hapusItem(item.barang.id, item.tipe), padding: EdgeInsets.zero, constraints: const BoxConstraints())]),
                Row(children: [
                  SizedBox(width: 50, child: TextField(keyboardType: TextInputType.number, controller: TextEditingController(text: item.qty.toString()), onSubmitted: (v){ final n=int.tryParse(v)??1; ref.read(cartProvider.notifier).updateQty(item.barang.id, item.tipe, n); }, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)), contentPadding: const EdgeInsets.symmetric(vertical: 4)))),
                  const SizedBox(width: 6),
                  Text('x Rp ${item.hargaJual.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                  const Spacer(),
                  Text('Rp ${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ]));
            })),
            const Divider(height: 1),
            Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Flexible(child: Text('Rp ${totalBelanja.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF10B981)), overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: cartItems.isEmpty? null: _prosesCheckout, child: const Text('PROSES PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)))),
            ])),
          ]))),
        ])),
      ]),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(label, style: TextStyle(fontSize: 11, color: selected? Colors.white: Colors.black)), selected: selected, onSelected: (_)=>onTap(), selectedColor: const Color(0xFF0F172A), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE2E8F0)))));
}