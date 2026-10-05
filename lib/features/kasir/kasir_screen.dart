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
  final namaPembeliCtrl = TextEditingController();
  FilterKategoriHarga filter = FilterKategoriHarga.semua;
  int topDays = 0;
  final Map<int, TextEditingController> qtyControllers = {};

  @override void dispose(){
    searchCtrl.dispose();
    namaPembeliCtrl.dispose();
    for(var c in qtyControllers.values) c.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context){
    final barangList = ref.watch(inventoryStreamProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sony Jaya - Kasir Pintar', style: TextStyle(fontWeight: FontWeight.w700, fontSize:18, color: Colors.black)),
      ),
      body: Row(children:[
        Expanded(flex: 65, child: Container(color: Colors.white, child: Column(children:[
          Padding(padding: const EdgeInsets.fromLTRB(16,16,16,8), child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cari nama / SKU',
              prefixIcon: const Icon(Icons.search_rounded, size:20),
              filled: true, fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (_)=> setState((){}),
          )),
          Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: FilterKategoriHarga.values.map((f){
            final sel = filter==f;
            final label = f==FilterKategoriHarga.semua?'Semua': f==FilterKategoriHarga.ecer?'Ecer': f==FilterKategoriHarga.agen?'Agen':'Margin Tinggi';
            return Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(
              label: Text(label, style: TextStyle(fontSize:12, color: sel? Colors.white: Colors.black87)),
              selected: sel,
              selectedColor: Colors.black,
              backgroundColor: const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (_)=> setState(()=> filter=f),
            ));
          }).toList()))),
          const SizedBox(height:8),
          Expanded(child: barangList.when(
            data: (list){
              var filtered = list.where((b)=> searchCtrl.text.isEmpty || b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase()) || (b.sku??'').toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
              if(filter==FilterKategoriHarga.marginTinggi) filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer-b.hppAverage)/b.hppAverage*100)>=30).toList();
              return ListView.builder(itemCount: filtered.length, padding: const EdgeInsets.fromLTRB(16,8,16,100), itemBuilder: (_,i){
                final b=filtered[i];
                final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: '1'));
                final marginEcer = b.hppAverage==0?0:(b.hargaEcer-b.hppAverage)/b.hppAverage*100;
                return Container(
                  margin: const EdgeInsets.only(bottom:12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Row(children:[
                      Expanded(child: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize:15))),
                      Container(padding: const EdgeInsets.symmetric(horizontal:10, vertical:5), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)), child: Text('Stok ${b.stok}', style: const TextStyle(fontSize:11, fontWeight: FontWeight.w700))),
                    ]),
                    const SizedBox(height:4),
                    Text('SKU ${b.sku??'-'} HPP Rp ${b.hppAverage.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, color: Color(0xFF6B7280))),
                    const SizedBox(height:14),
                    Row(children:[
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                        const Text('QTY', style: TextStyle(fontSize:9, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                        const SizedBox(height:4),
                        SizedBox(width:72, height:48, child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize:16), decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB)))))),
                      ]),
                      const SizedBox(width:10),
                      Expanded(child: SizedBox(height:48, child: ElevatedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.ecer); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('ECER Rp ${b.hargaEcer.toStringAsFixed(0)}')))),
                      const SizedBox(width:8),
                      Expanded(child: SizedBox(height:48, child: OutlinedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.agen); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD1D5DB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('AGEN Rp ${b.hargaAgen.toStringAsFixed(0)}')))),
                    ]),
                  ]),
                );
              });
            },
            loading: ()=> const Center(child: CircularProgressIndicator()),
            error: (e,_ )=> Center(child: Text('Error $e')),
          )),
        ]))),
        Expanded(flex: 35, child: Container(color: const Color(0xFFF9FAFB), child: Column(children:[
          Container(padding: const EdgeInsets.all(16), color: Colors.white, child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w700, fontSize:14)), Text('${cart.length} item')]),
            const SizedBox(height:12),
            TextField(controller: namaPembeliCtrl, decoration: InputDecoration(hintText: 'Nama Pembeli (kosong = Umum)', isDense:true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height:8),
            DropdownButtonFormField<int>(value: topDays, decoration: InputDecoration(labelText: 'TOP / Tempo', isDense:true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: const [DropdownMenuItem(value:0, child:Text('0 - TUNAI')), DropdownMenuItem(value:7, child:Text('7 hari HITAM')), DropdownMenuItem(value:14, child:Text('14 hari HITAM')), DropdownMenuItem(value:30, child:Text('30 hari KUNING')), DropdownMenuItem(value:60, child:Text('60 hari MERAH'))], onChanged: (v)=> setState(()=> topDays=v??0)),
          ])),
          Expanded(child: cart.isEmpty? const Center(child: Text('Keranjang kosong')) : ListView.builder(itemCount: cart.length, padding: const EdgeInsets.all(12), itemBuilder: (_,i){
            final it=cart[i];
            final tipeLabel = it.tipe==TipeHarga.ecer ? 'ECER' : 'AGEN';
            final totalItem = it.qty * it.hargaJual;
            return Container(margin: const EdgeInsets.only(bottom:8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children:[
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text(it.barang.nama, style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600), maxLines:1, overflow: TextOverflow.ellipsis),
                Text('x${it.qty} $tipeLabel Rp ${it.hargaJual.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, color: Color(0xFF6B7280))),
              ])),
              Text('Rp ${totalItem.toStringAsFixed(0)}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w700)),
              IconButton(icon: const Icon(Icons.close_rounded, size:18), onPressed: ()=> ref.read(cartProvider.notifier).hapusItem(it.barang.id, it.tipe)),
            ]));
          })),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))), child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Total:'), Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize:20))]),
            const SizedBox(height:12),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: total<=0? null: () async {
                await ref.read(cartProvider.notifier).checkout(
                  pelangganNama: namaPembeliCtrl.text.trim().isEmpty? null : namaPembeliCtrl.text.trim(),
                  topDays: topDays,
                  noNota: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                );
                namaPembeliCtrl.clear();
                setState(()=> topDays=0);
                if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi Rp ${total.toStringAsFixed(0)} berhasil')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('PROSES PEMBAYARAN'))),
          ])),
        ]))),
      ]),
    );
  }
}
