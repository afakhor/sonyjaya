import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
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

  String formatRp(double n) => "Rp ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m)=> '${m[1]}.')}";

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
    final isWide = MediaQuery.of(context).size.width >= 800;
    final cartCount = cart.fold<int>(0, (s,i)=> s+i.qty);
    final produkCount = barangList.maybeWhen(data: (l)=> l.length, orElse: ()=> 0);

    Widget leftPanel(){
      return Container(
        decoration: isWide? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF3F4F6))): const BoxDecoration(color: Colors.white),
        child: Column(children:[
          Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
              Row(children:[Container(width:28, height:28, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Center(child: Text("K", style: TextStyle(color: Colors.white, fontSize:11, fontWeight: FontWeight.bold))),), const SizedBox(width:8), const Text("KASIR PINTAR • TOKO", style: TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))]),
              Row(children:[Container(width:8, height:8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)), const SizedBox(width:6), const Text("Online", style: TextStyle(fontSize:11, color: Color(0xFF9CA3AF)))])
            ]),
            const SizedBox(height:12),
            const Text("Produk", style: TextStyle(fontSize:28, fontWeight: FontWeight.w700, letterSpacing:-0.5, height:1)),
            const SizedBox(height:6),
            Text("$produkCount produk • Stok terkelola", style: const TextStyle(fontSize:13, color: Color(0xFF9CA3AF))),
            const SizedBox(height:24),
            TextField(
              controller: searchCtrl,
              onChanged: (_)=> setState((){}),
              decoration: InputDecoration(
                hintText: "Cari nama / SKU",
                prefixIcon: const Icon(Icons.search_rounded, size:18, color: Color(0xFF9CA3AF)),
                filled: true, fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width:1.2)),
              ),
            ),
            const SizedBox(height:16),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: FilterKategoriHarga.values.map((f){
              final sel = filter==f;
              final label = f==FilterKategoriHarga.semua?"Semua": f==FilterKategoriHarga.ecer?"Ecer": f==FilterKategoriHarga.agen?"Agen":"Margin Tinggi";
              return Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(
                label: Text(label, style: TextStyle(fontSize:13, color: sel? Colors.white: const Color(0xFF6B7280))),
                selected: sel,
                selectedColor: const Color(0xFF111827),
                backgroundColor: Colors.white,
                side: BorderSide(color: sel? const Color(0xFF111827): const Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                onSelected: (_)=> setState(()=> filter=f),
              ));
            }).toList())),
          ])),
          const Divider(height:1, color: Color(0xFFF9FAFB)),
          Expanded(child: barangList.when(
            data: (list){
              var filtered = list.where((b)=> searchCtrl.text.isEmpty || b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase()) || (b.sku??"").toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
              if(filter==FilterKategoriHarga.marginTinggi) filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer-b.hppAverage)/b.hppAverage*100)>=30).toList();
              if(filtered.isEmpty) return const Center(child: Text("Tidak ada barang"));
              return ListView.builder(itemCount: filtered.length, padding: const EdgeInsets.fromLTRB(16,16,16,100), physics: const BouncingScrollPhysics(), itemBuilder: (_,i){
                final b=filtered[i];
                final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: "1"));
                final marginEcer = b.hppAverage==0?0:(b.hargaEcer-b.hppAverage)/b.hppAverage*100;
                final marginAgen = b.hppAverage==0?0:(b.hargaAgen-b.hppAverage)/b.hppAverage*100;
                return Container(
                  margin: const EdgeInsets.only(bottom:16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                      Expanded(child: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize:14))),
                      Container(padding: const EdgeInsets.symmetric(horizontal:10, vertical:5), decoration: BoxDecoration(color: b.stok<=b.safetyStock? const Color(0xFFFEF2F2): const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)), child: Text("Stok ${b.stok}", style: TextStyle(fontSize:11, fontWeight: FontWeight.w700, color: b.stok<=b.safetyStock? Colors.red: const Color(0xFF374151)))),
                    ]),
                    const SizedBox(height:4),
                    Text("SKU ${b.sku??'-'} HPP ${formatRp(b.hppAverage)}", style: const TextStyle(fontSize:11, color: Color(0xFF9CA3AF))),
                    const SizedBox(height:14),
                    Row(children:[
                      Container(width:88, height:48, decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children:[
                        InkWell(onTap: (){ final q=int.tryParse(qtyCtrl.text)??1; if(q>1) setState(()=> qtyCtrl.text="${q-1}"); }, child: const SizedBox(width:28, height:48, child: Icon(Icons.remove, size:14))),
                        Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize:15), decoration: const InputDecoration(border: InputBorder.none, isDense:true))),
                        InkWell(onTap: (){ final q=int.tryParse(qtyCtrl.text)??1; setState(()=> qtyCtrl.text="${q+1}"); }, child: const SizedBox(width:28, height:48, child: Icon(Icons.add, size:14))),
                      ])),
                      const SizedBox(width:10),
                      Expanded(child: SizedBox(height:48, child: ElevatedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.ecer); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111827), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[const Text("ECER", style: TextStyle(fontSize:11, fontWeight: FontWeight.w700)), Text("${formatRp(b.hargaEcer)} ${marginEcer.toStringAsFixed(0)}%", style: const TextStyle(fontSize:10))])))),
                      const SizedBox(width:8),
                      Expanded(child: SizedBox(height:48, child: OutlinedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; if(qty>0) ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.agen); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[const Text("AGEN", style: TextStyle(fontSize:11, fontWeight: FontWeight.w700, color: Colors.black)), Text("${formatRp(b.hargaAgen)} ${marginAgen.toStringAsFixed(0)}%", style: const TextStyle(fontSize:10, color: Color(0xFF6B7280)))])))),
                    ]),
                  ]),
                );
              });
            },
            loading: ()=> const Center(child: CircularProgressIndicator()),
            error: (e,_ )=> Center(child: Text("Error $e")),
          )),
        ]),
      );
    }

    Widget rightPanel(){
      return Container(
        decoration: isWide? BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF3F4F6))): const BoxDecoration(color: Color(0xFFF9FAFB)),
        child: Column(children:[
          Padding(padding: const EdgeInsets.fromLTRB(20,28,20,20), child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
              Row(children:[const Text("Keranjang", style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)), const SizedBox(width:10), Text("$cartCount item", style: const TextStyle(fontSize:13, color: Color(0xFF9CA3AF)))]),
              if(cart.isNotEmpty) InkWell(onTap: ()=> ref.read(cartProvider.notifier).clearCart(), child: const Text("Kosongkan X", style: TextStyle(fontSize:12, color: Color(0xFF9CA3AF)))),
            ]),
            const SizedBox(height:16),
            TextField(controller: namaPembeliCtrl, decoration: InputDecoration(hintText: "Nama Pembeli opsional", isDense:true, filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))))),
            const SizedBox(height:8),
            DropdownButtonFormField<int>(value: topDays, decoration: InputDecoration(labelText: "TOP / Tempo", isDense:true, filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB)))), items: const [DropdownMenuItem(value:0, child:Text("0 - TUNAI Lunas")), DropdownMenuItem(value:7, child:Text("7 hari HITAM")), DropdownMenuItem(value:14, child:Text("14 hari HITAM")), DropdownMenuItem(value:30, child:Text("30 hari KUNING")), DropdownMenuItem(value:60, child:Text("60 hari MERAH"))], onChanged: (v)=> setState(()=> topDays=v??0)),
          ])),
          Expanded(child: cart.isEmpty? const Center(child: Text("Keranjang kosong")): ListView.builder(itemCount: cart.length, padding: const EdgeInsets.symmetric(horizontal:12), physics: const BouncingScrollPhysics(), itemBuilder: (_,i){
            final it=cart[i];
            final tipeLabel = it.tipe==TipeHarga.ecer ? "ECER" : "AGEN";
            return Container(margin: const EdgeInsets.only(bottom:10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF3F4F6))), child: Row(children:[
              Container(width:40, height:40, decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(tipeLabel, style: const TextStyle(color: Colors.white, fontSize:10, fontWeight: FontWeight.bold)))),
              const SizedBox(width:12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                  Expanded(child: Text(it.barang.nama, style: const TextStyle(fontSize:13, fontWeight: FontWeight.w600), maxLines:1, overflow: TextOverflow.ellipsis)),
                  InkWell(onTap: ()=> ref.read(cartProvider.notifier).hapusItem(it.barang.id, it.tipe), child: const Icon(Icons.close_rounded, size:16, color: Color(0xFFD1D5DB))),
                ]),
                Text("x${it.qty} $tipeLabel", style: const TextStyle(fontSize:11, color: Color(0xFF9CA3AF))),
              ])),
              Text(formatRp(it.qty*it.hargaJual), style: const TextStyle(fontSize:13, fontWeight: FontWeight.w700)),
            ]));
          })),
          Container(padding: const EdgeInsets.fromLTRB(20,16,20,20), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF3F4F6))), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))), child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text("Total"), Text(formatRp(total), style: const TextStyle(fontSize:20, fontWeight: FontWeight.w700, color: Color(0xFF059669)))]),
            const SizedBox(height:16),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: total<=0? null: () async {
                final nota = "INV-${DateTime.now().millisecondsSinceEpoch}";
                final nama = namaPembeliCtrl.text.trim().isEmpty ? "Umum" : namaPembeliCtrl.text.trim();
                final totalStr = formatRp(total);
                await ref.read(cartProvider.notifier).checkout(pelangganNama: nama=="Umum"? null : nama, topDays: topDays, noNota: nota);
                if(!context.mounted) return;
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_)=> Padding(padding: EdgeInsets.fromLTRB(20,20,20, MediaQuery.of(context).viewInsets.bottom+20), child: Column(mainAxisSize: MainAxisSize.min, children:[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                    const Text("Nota Preview", style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
                    Row(children:[
                      IconButton(onPressed: (){ Share.share("Nota $nota\nTotal $totalStr\nPelanggan: $nama\nTerima kasih belanja di Sony Jaya"); }, icon: const Icon(Icons.share_rounded)),
                      IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ]),
                  ]),
                  const SizedBox(height:12),
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Text("No: $nota", style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600)),
                    Text("Pelanggan: $nama | TOP $topDays hari", style: const TextStyle(fontSize:12)),
                    const Divider(),
                    Text("Total: $totalStr", style: const TextStyle(fontSize:16, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ])),
                  const SizedBox(height:16),
                  SizedBox(width: double.infinity, height:48, child: ElevatedButton(onPressed: ()=> Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("SELESAI - X"))),
                ])),
                );
                namaPembeliCtrl.clear();
                setState(()=> topDays=0);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111827), disabledBackgroundColor: const Color(0xFFE5E7EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("PROSES PEMBAYARAN"))),
          ])),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: isWide? AppBar(backgroundColor: const Color(0xFFF9FAFB), elevation:0, toolbarHeight:0): AppBar(backgroundColor: Colors.white, elevation:0, title: const Text("Sony Jaya - Kasir Pintar", style: TextStyle(color: Colors.black, fontSize:18, fontWeight: FontWeight.w700))),
      body: isWide? Padding(padding: const EdgeInsets.all(12), child: Row(children:[Expanded(flex:65, child: leftPanel()), const SizedBox(width:12), Expanded(flex:35, child: rightPanel())])) : Column(children:[Expanded(child: leftPanel()), SizedBox(height:400, child: rightPanel())]),
    );
  }
}
