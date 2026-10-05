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
        actions: [
          if(searchCtrl.text.isNotEmpty || filter!=FilterKategoriHarga.semua)
            IconButton(onPressed: ()=> setState((){ searchCtrl.clear(); filter=FilterKategoriHarga.semua; }), icon: const Icon(Icons.delete_sweep_rounded, color: Colors.black87)),
          const SizedBox(width:8),
        ],
      ),
      body: Row(children:[
        Expanded(flex: 65, child: Container(color: Colors.white, child: Column(children:[
          Padding(padding: const EdgeInsets.fromLTRB(16,16,16,8), child: TextField(
            controller: searchCtrl,
            style: const TextStyle(fontSize:14),
            decoration: InputDecoration(
              hintText: 'Cari nama / SKU',
              prefixIcon: const Icon(Icons.search_rounded, size:20),
              filled: true, fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical:14),
            ),
            onChanged: (_)=> setState((){}),
          )),
          Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: FilterKategoriHarga.values.map((f){
            final sel = filter==f;
            final label = f==FilterKategoriHarga.semua?'Semua': f==FilterKategoriHarga.ecer?'Ecer': f==FilterKategoriHarga.agen?'Agen':'Margin Tinggi';
            return Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(
              label: Text(label, style: TextStyle(fontSize:12, fontWeight: sel? FontWeight.w700: FontWeight.w500, color: sel? Colors.white: Colors.black87)),
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
              if(filtered.isEmpty) return const Center(child: Text('Tidak ada barang', style: TextStyle(color: Colors.grey)));
              return ListView.builder(itemCount: filtered.length, padding: const EdgeInsets.fromLTRB(16,8,16,100), itemBuilder: (_,i){
                final b=filtered[i];
                final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: '1'));
                final marginEcer = b.hppAverage==0?0:(b.hargaEcer-b.hppAverage)/b.hppAverage*100;
                final marginAgen = b.hppAverage==0?0:(b.hargaAgen-b.hppAverage)/b.hppAverage*100;
                return Container(
                  margin: const EdgeInsets.only(bottom:12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,2))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Row(children:[
                      Expanded(child: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize:15, color: Color(0xFF111827)))),
                      Container(padding: const EdgeInsets.symmetric(horizontal:10, vertical:5), decoration: BoxDecoration(color: b.stok<=b.safetyStock? const Color(0xFFFEF2F2): const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)), child: Text('Stok ${b.stok}', style: TextStyle(fontSize:11, fontWeight: FontWeight.w700, color: b.stok<=b.safetyStock? Colors.red: const Color(0xFF374151)))),
                    ]),
                    const SizedBox(height:4),
                    Text('SKU ${b.sku??'-'} • HPP Rp ${b.hppAverage.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, color: Color(0xFF6B7280))),
                    const SizedBox(height:10),
                    Row(children:[
                      Text('Ecer: Rp ${b.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600)),
                      const SizedBox(width:8),
                      Container(padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)), child: Text('${marginEcer.toStringAsFixed(0)}%', style: const TextStyle(fontSize:10, fontWeight: FontWeight.w700, color: Color(0xFF059669)))),
                      const SizedBox(width:12),
                      Text('Agen: Rp ${b.hargaAgen.toStringAsFixed(0)}', style: const TextStyle(fontSize:12, color: Color(0xFF6B7280))),
                    ]),
                    const SizedBox(height:14),
                    Row(children:[
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                        const Text('QTY', style: TextStyle(fontSize:9, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing:1)),
                        const SizedBox(height:4),
                        SizedBox(width:72, height:48, child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize:16), decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))), contentPadding: const EdgeInsets.symmetric(vertical:12)))),
                      ]),
                      const SizedBox(width:10),
                      Expanded(child: SizedBox(height:48, child: ElevatedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.ecer); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation:0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[const Text('ECER', style: TextStyle(fontSize:11, fontWeight: FontWeight.w800)), Text('Rp ${b.hargaEcer.toStringAsFixed(0)}', style: const TextStyle(fontSize:11))])))),
                      const SizedBox(width:8),
                      Expanded(child: SizedBox(height:48, child: OutlinedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.agen); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD1D5DB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[const Text('AGEN', style: TextStyle(fontSize:11, fontWeight: FontWeight.w800, color: Colors.black)), Text('Rp ${b.hargaAgen.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, color: Colors.black))])))),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w700, fontSize:14)), Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)), child: Text('${cart.length} item', style: const TextStyle(fontSize:11, fontWeight: FontWeight.w600)))]),
            const SizedBox(height:12),
            TextField(controller: namaPembeliCtrl, decoration: InputDecoration(hintText: 'Nama Pembeli (kosong = Umum)', isDense:true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal:12, vertical:10), prefixIcon: const Icon(Icons.person_outline, size:18))),
            const SizedBox(height:8),
            DropdownButtonFormField<int>(value: topDays, decoration: InputDecoration(labelText: 'TOP / Tempo', isDense:true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: const [DropdownMenuItem(value:0, child:Text('0 - TUNAI (Lunas)')), DropdownMenuItem(value:7, child:Text('7 hari - HITAM')), DropdownMenuItem(value:14, child:Text('14 hari - HITAM')), DropdownMenuItem(value:30, child:Text('30 hari - KUNING')), DropdownMenuItem(value:60, child:Text('60 hari - MERAH'))], onChanged: (v)=> setState(()=> topDays=v??0)),
          ])),
          Expanded(child: cart.isEmpty? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.shopping_bag_outlined, size:36, color: Color(0xFFD1D5DB)), SizedBox(height:12), Text('Keranjang kosong', style: TextStyle(color: Color(0xFF9CA3AF), fontSize:13))])) : ListView.builder(itemCount: cart.length, padding: const EdgeInsets.all(12), itemBuilder: (_,i){ final it=cart[i]; return Container(margin: const EdgeInsets.only(bottom:8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children:[Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('${it.barang.nama}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600), maxLines:1, overflow: TextOverflow.ellipsis), Text('x${it.qty} ${it.tipe==TipeHarga.ecer?'ECER':'AGEN'} • Rp ${it.hargaJual.toStringAsFixed(0)}', style: const TextStyle(fontSize:11, color: Color(0xFF6B7280))])), Text('Rp ${(it.qty*it.hargaJual).toStringAsFixed(0)}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w700)), IconButton(icon: const Icon(Icons.close_rounded, size:18), onPressed: ()=> ref.read(cartProvider.notifier).hapusItem(it.barang.id, it.tipe))])) ;})),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))), child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Total:', style: TextStyle(fontWeight: FontWeight.w600, fontSize:13, color: Color(0xFF6B7280))), Text('Rp ${total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize:20, color: total>0? Color(0xFF059669): Color(0xFF9CA3AF)))]),
            const SizedBox(height:12),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: total<=0? null: () async {
                // FIX: pakai pelangganNama bukan namaPelanggan
                await ref.read(cartProvider.notifier).checkout(
                  pelangganNama: namaPembeliCtrl.text.trim().isEmpty? null : namaPembeliCtrl.text.trim(),
                  topDays: topDays,
                  noNota: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                );
                namaPembeliCtrl.clear();
                setState(()=> topDays=0);
                if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi Rp ${total.toStringAsFixed(0)} berhasil - Laba, Piutang, Rating auto update'), backgroundColor: Colors.black));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, disabledBackgroundColor: const Color(0xFFE5E7EB), foregroundColor: Colors.white, elevation:0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('PROSES PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w800, fontSize:13, letterSpacing:0.5)))),
          ])),
        ]))),
      ]),
    );
  }
}
