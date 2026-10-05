import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/kasir_provider.dart';

class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});
  @override ConsumerState<KasirScreen> createState()=> _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  final searchCtrl = TextEditingController();
  FilterKategoriHarga filter = FilterKategoriHarga.semua;
  final Map<int, TextEditingController> qtyControllers = {};

  @override void dispose(){
    searchCtrl.dispose();
    for(var c in qtyControllers.values){ c.dispose(); }
    super.dispose();
  }

  @override Widget build(BuildContext context){
    final barangList = ref.watch(inventoryStreamProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sony Jaya - Kasir Pintar', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Clear filter',
            onPressed: (){
              setState((){ searchCtrl.clear(); filter = FilterKategoriHarga.semua; });
            },
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: Row(children:[
        Expanded(flex: 3, child: Column(children:[
          Padding(padding: const EdgeInsets.all(10), child: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'nama / sku / merek', border: OutlineInputBorder()),
            onChanged: (v)=> setState((){}),
          )),
          SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal:10), child: Row(children: FilterKategoriHarga.values.map((f){
            final sel = filter==f;
            return Padding(padding: const EdgeInsets.only(right:6), child: ChoiceChip(label: Text(f==FilterKategoriHarga.semua?'Semua': f==FilterKategoriHarga.ecer?'Ecer': f==FilterKategoriHarga.agen?'Agen':'Margin Tinggi'), selected: sel, onSelected: (_)=> setState(()=> filter=f)));
          }).toList())),
          Expanded(child: barangList.when(
            data: (list){
              var filtered = list;
              if(searchCtrl.text.isNotEmpty){
                filtered = filtered.where((b)=> b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase()) || (b.sku??'').toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
              }
              if(filter==FilterKategoriHarga.marginTinggi){
                filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer - b.hppAverage)/b.hppAverage*100)>=30).toList();
              }
              return ListView.builder(itemCount: filtered.length, padding: const EdgeInsets.only(bottom:80), itemBuilder: (c,i){
                final b=filtered[i];
                final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: '1'));
                final marginEcer = b.hppAverage==0?0:(b.hargaEcer-b.hppAverage)/b.hppAverage*100;
                final marginAgen = b.hppAverage==0?0:(b.hargaAgen-b.hppAverage)/b.hppAverage*100;

                return Card(margin: const EdgeInsets.symmetric(horizontal:10, vertical:6), elevation: 1, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                    Expanded(child: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:14))),
                    Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: b.stok<=b.safetyStock? Colors.red.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text('Stok ${b.stok}', style: TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: b.stok<=b.safetyStock? Colors.red: Colors.black))),
                  ]),
                  Text('SKU ${b.sku??'-'} | HPP Rp ${b.hppAverage.toStringAsFixed(0)}', style: TextStyle(fontSize:11, color: Colors.grey.shade600)),
                  const SizedBox(height:10),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children:[
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                      const Text('QTY', style: TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height:2),
                      SizedBox(width: 70, height: 48, child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize:16),
                        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true, contentPadding: const EdgeInsets.symmetric(vertical:12)),
                      )),
                    ]),
                    const SizedBox(width:8),
                    Expanded(child: SizedBox(height: 48, child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal:4)),
                      onPressed: (){
                        final qty = int.tryParse(qtyCtrl.text)??1;
                        if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.ecer);
                      },
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
                        const Text('ECER', style: TextStyle(fontSize:11, fontWeight: FontWeight.w800)),
                        Text('Rp ${b.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, fontWeight: FontWeight.bold)),
                        Text('${marginEcer.toStringAsFixed(0)}%', style: const TextStyle(fontSize:9, color: Colors.greenAccent)),
                      ]),
                    ))),
                    const SizedBox(width:6),
                    Expanded(child: SizedBox(height: 48, child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal:4)),
                      onPressed: (){
                        final qty = int.tryParse(qtyCtrl.text)??1;
                        if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.agen);
                      },
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
                        const Text('AGEN', style: TextStyle(fontSize:11, fontWeight: FontWeight.w800, color: Colors.black)),
                        Text('Rp ${b.hargaAgen.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text('${marginAgen.toStringAsFixed(0)}%', style: TextStyle(fontSize:9, color: Colors.orange.shade800)),
                      ]),
                    ))),
                  ]),
                ])));
              });
            },
            loading: ()=> const Center(child: CircularProgressIndicator()),
            error: (e,_ )=> Center(child: Text('Error $e')),
          )),
        ])),
        Expanded(flex: 2, child: Container(decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade300)), color: Colors.grey.shade50), child: Column(children:[
          Padding(padding: const EdgeInsets.all(10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.bold)), Text('${cart.length} item')])),
          Expanded(child: cart.isEmpty? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.shopping_cart_outlined, size:40, color: Colors.grey), SizedBox(height:8), Text('Keranjang kosong', style: TextStyle(color: Colors.grey))])) : ListView.builder(itemCount: cart.length, itemBuilder: (c,i){
            final item=cart[i];
            return ListTile(dense: true, title: Text('${item.barang.nama} x${item.qty} ${item.tipe==TipeHarga.ecer?'ECER':'AGEN'}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.bold)), subtitle: Text('Rp ${(item.qty*item.hargaJual).toStringAsFixed(0)}'), trailing: IconButton(icon: const Icon(Icons.close, size:18), onPressed: ()=> ref.read(cartProvider.notifier).hapusItem(item.barang.id, item.tipe)));
          })),
          const Divider(),
          Padding(padding: const EdgeInsets.all(12), child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)), Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:18, color: Colors.green))]),
            const SizedBox(height:10),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: total<=0? null : () async {
                await ref.read(cartProvider.notifier).checkout();
                if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi Rp ${total.toStringAsFixed(0)} berhasil! Cek Laba & Piutang sekarang ada')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: total>0? Colors.black : Colors.grey.shade400, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('PROSES PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w800, fontSize:14)),
            )),
          ])),
        ]))),
      ]),
    );
  }
}
