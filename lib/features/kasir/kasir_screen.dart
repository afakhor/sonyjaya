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

    // DESKTOP / TABLET - Row 65/35 persis sonyjaya.html
    if(isWide){
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children:[
            Expanded(flex:65, child: _buildProdukPanel(produkCount, barangList, isWide)),
            const SizedBox(width:12),
            Expanded(flex:35, child: _buildKeranjangPanel(cart, cartCount, total, isWide)),
          ]),
        ),
      );
    }

    // HP - Single ScrollView biar tidak amburadul tertutup
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(backgroundColor: Colors.white, elevation:0, title: const Text("Sony Jaya - Kasir Pintar", style: TextStyle(color: Colors.black, fontSize:18, fontWeight: FontWeight.w700))),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children:[
          _buildProdukPanelHP(produkCount, barangList),
          const SizedBox(height:8),
          _buildKeranjangPanelHP(cart, cartCount, total),
          const SizedBox(height:80),
        ]),
      ),
    );
  }

  Widget _buildProdukPanel(int produkCount, AsyncValue<List<BarangData>> barangList, bool isWide){
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(children:[
        Padding(padding: const EdgeInsets.fromLTRB(20,28,20,20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
            Row(children:[Container(width:28, height:28, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Center(child: Text("K", style: TextStyle(color: Colors.white, fontSize:11, fontWeight: FontWeight.bold))),), const SizedBox(width:8), const Text("KASIR PINTAR • TOKO", style: TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))]),
            Row(children:[Container(width:8, height:8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)), const SizedBox(width:6), const Text("Online", style: TextStyle(fontSize:11, color: Color(0xFF9CA3AF)))])
          ]),
          const SizedBox(height:12),
          const Text("Produk", style: TextStyle(fontSize:28, fontWeight: FontWeight.w700)),
          const SizedBox(height:6),
          Text("$produkCount produk • Stok terkelola", style: const TextStyle(fontSize:13, color: Color(0xFF9CA3AF))),
          const SizedBox(height:24),
          TextField(controller: searchCtrl, onChanged: (_)=> setState((){}), decoration: InputDecoration(hintText: "Cari nama / SKU", prefixIcon: const Icon(Icons.search_rounded, size:18), filled:true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))))),
          const SizedBox(height:16),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: FilterKategoriHarga.values.map((f){
            final sel = filter==f;
            final label = f==FilterKategoriHarga.semua?"Semua": f==FilterKategoriHarga.ecer?"Ecer": f==FilterKategoriHarga.agen?"Agen":"Margin Tinggi";
            return Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(label: Text(label, style: TextStyle(fontSize:13, color: sel? Colors.white: const Color(0xFF6B7280))), selected: sel, selectedColor: const Color(0xFF111827), backgroundColor: Colors.white, side: BorderSide(color: sel? const Color(0xFF111827): const Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), onSelected: (_)=> setState(()=> filter=f)));
          }).toList())),
        ])),
        const Divider(height:1),
        SizedBox(height:500, child: _barangListView(barangList)),
      ]),
    );
  }

  Widget _buildProdukPanelHP(int produkCount, AsyncValue<List<BarangData>> barangList){
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20,20,20,20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
          Row(children:[Container(width:28, height:28, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Center(child: Text("K", style: TextStyle(color: Colors.white, fontSize:11, fontWeight: FontWeight.bold))),), const SizedBox(width:8), const Text("KASIR PINTAR • TOKO", style: TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))]),
          Row(children:[Container(width:8, height:8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)), const SizedBox(width:6), const Text("Online", style: TextStyle(fontSize:11, color: Color(0xFF9CA3AF)))])
        ]),
        const SizedBox(height:12),
        const Text("Produk", style: TextStyle(fontSize:28, fontWeight: FontWeight.w700)),
        Text("$produkCount produk • Stok terkelola", style: const TextStyle(fontSize:13, color: Color(0xFF9CA3AF))),
        const SizedBox(height:20),
        TextField(controller: searchCtrl, onChanged: (_)=> setState((){}), decoration: InputDecoration(hintText: "Cari nama / SKU", prefixIcon: const Icon(Icons.search_rounded), filled:true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))))),
        const SizedBox(height:12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: FilterKategoriHarga.values.map((f){
          final sel = filter==f;
          final label = f==FilterKategoriHarga.semua?"Semua": f==FilterKategoriHarga.ecer?"Ecer": f==FilterKategoriHarga.agen?"Agen":"Margin Tinggi";
          return Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(label: Text(label), selected: sel, selectedColor: const Color(0xFF111827), onSelected: (_)=> setState(()=> filter=f)));
        }).toList())),
        const SizedBox(height:20),
        _barangListViewHP(barangList),
      ]),
    );
  }

  Widget _barangListView(AsyncValue<List<BarangData>> barangList){
    return barangList.when(
      data: (list){
        var filtered = list.where((b)=> searchCtrl.text.isEmpty || b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase()) || (b.sku??"").toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
        if(filter==FilterKategoriHarga.marginTinggi) filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer-b.hppAverage)/b.hppAverage*100)>=30).toList();
        if(filtered.isEmpty) return const Center(child: Text("Tidak ada barang - tambah di Stok"));
        return ListView.builder(itemCount: filtered.length, padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(), itemBuilder: (_,i){
          final b=filtered[i];
          final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: "1"));
          final marginEcer = b.hppAverage==0?0:(b.hargaEcer-b.hppAverage)/b.hppAverage*100;
          return Container(margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(16)), child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Expanded(child: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700))), Text("Stok ${b.stok}", style: const TextStyle(fontSize:11, fontWeight: FontWeight.w700))]),
            const SizedBox(height:10),
            Row(children:[
              SizedBox(width:70, child: TextField(controller: qtyCtrl, textAlign: TextAlign.center, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense:true))),
              const SizedBox(width:8),
              Expanded(child: ElevatedButton(onPressed: (){ final q=int.tryParse(qtyCtrl.text)??1; ref.read(cartProvider.notifier).tambahItem(b, qty:q, tipeHarga:TipeHarga.ecer); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: Text("ECER ${formatRp(b.hargaEcer)}"))),
              const SizedBox(width:6),
              Expanded(child: OutlinedButton(onPressed: (){ final q=int.tryParse(qtyCtrl.text)??1; ref.read(cartProvider.notifier).tambahItem(b, qty:q, tipeHarga:TipeHarga.agen); }, child: Text("AGEN ${formatRp(b.hargaAgen)}"))),
            ]),
          ]));
        });
      },
      loading: ()=> const Center(child: CircularProgressIndicator()),
      error: (e,_ )=> Center(child: Text("Error $e")),
    );
  }

  Widget _barangListViewHP(AsyncValue<List<BarangData>> barangList){
    return barangList.when(
      data: (list){
        var filtered = list.where((b)=> searchCtrl.text.isEmpty || b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase()) || (b.sku??"").toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
        if(filter==FilterKategoriHarga.marginTinggi) filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer-b.hppAverage)/b.hppAverage*100)>=30).toList();
        if(filtered.isEmpty) return Container(padding: const EdgeInsets.symmetric(vertical:40), child: const Center(child: Text("Tidak ada barang - tambah di menu Stok dulu")));
        return Column(children: filtered.map((b){
          final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: "1"));
          return Container(margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text("SKU ${b.sku??'-'} • Stok ${b.stok} • ${formatRp(b.hppAverage)}", style: const TextStyle(fontSize:11, color: Color(0xFF9CA3AF))),
            const SizedBox(height:10),
            Row(children:[
              SizedBox(width:60, child: TextField(controller: qtyCtrl, textAlign: TextAlign.center, decoration: const InputDecoration(border: OutlineInputBorder(), isDense:true))),
              const SizedBox(width:8),
              Expanded(child: ElevatedButton(onPressed: (){ final q=int.tryParse(qtyCtrl.text)??1; ref.read(cartProvider.notifier).tambahItem(b, qty:q, tipeHarga:TipeHarga.ecer); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: Text("ECER"))),
              const SizedBox(width:6),
              Expanded(child: OutlinedButton(onPressed: (){ final q=int.tryParse(qtyCtrl.text)??1; ref.read(cartProvider.notifier).tambahItem(b, qty:q, tipeHarga:TipeHarga.agen); }, child: const Text("AGEN"))),
            ]),
          ]));
        }).toList());
      },
      loading: ()=> const Center(child: CircularProgressIndicator()),
      error: (e,_ )=> Center(child: Text("Error $e")),
    );
  }

  Widget _buildKeranjangPanel(List<CartItem> cart, int cartCount, double total, bool isWide){
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(children:[
        Padding(padding: const EdgeInsets.all(20), child: Column(children:[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Text("Keranjang $cartCount item", style: const TextStyle(fontWeight: FontWeight.w700, fontSize:18)), if(cart.isNotEmpty) InkWell(onTap: ()=> ref.read(cartProvider.notifier).clearCart(), child: const Text("Kosongkan X", style: TextStyle(color: Color(0xFF9CA3AF))))]),
          const SizedBox(height:12),
          TextField(controller: namaPembeliCtrl, decoration: InputDecoration(hintText: "Nama Pembeli opsional", filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height:8),
          DropdownButtonFormField<int>(value: topDays, decoration: InputDecoration(labelText: "TOP / Tempo", filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: const [DropdownMenuItem(value:0, child:Text("0 - TUNAI Lunas")), DropdownMenuItem(value:7, child:Text("7 hari HITAM")), DropdownMenuItem(value:14, child:Text("14 hari HITAM")), DropdownMenuItem(value:30, child:Text("30 hari KUNING"))], onChanged: (v)=> setState(()=> topDays=v??0)),
        ])),
        Expanded(child: cart.isEmpty? const Center(child: Text("Keranjang kosong")): ListView.builder(itemCount: cart.length, itemBuilder: (_,i){ final it=cart[i]; return ListTile(title: Text(it.barang.nama), subtitle: Text("x${it.qty} ${it.tipe==TipeHarga.ecer?"ECER":"AGEN"}"), trailing: Row(mainAxisSize: MainAxisSize.min, children:[Text(formatRp(it.qty*it.hargaJual)), IconButton(icon: const Icon(Icons.close), onPressed: ()=> ref.read(cartProvider.notifier).hapusItem(it.barang.id, it.tipe))])); })),
        Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))), child: Column(children:[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text("Total"), Text(formatRp(total), style: const TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Color(0xFF059669)))]),
          const SizedBox(height:12),
          SizedBox(width: double.infinity, height:52, child: ElevatedButton(onPressed: total<=0? null: () async { final nota="INV-${DateTime.now().millisecondsSinceEpoch}"; final nama=namaPembeliCtrl.text.trim().isEmpty? "Umum": namaPembeliCtrl.text.trim(); await ref.read(cartProvider.notifier).checkout(pelangganNama: nama=="Umum"? null: nama, topDays: topDays, noNota: nota); if(!context.mounted) return; showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_)=> Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children:[Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text("Nota Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize:18)), Row(children:[IconButton(onPressed: (){ Share.share("Nota $nota Total ${formatRp(total)} Pelanggan $nama"); }, icon: const Icon(Icons.share)), IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))])]), Text("No: $nota"), Text("Pelanggan: $nama | TOP $topDays hari"), const SizedBox(height:12), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=> Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text("SELESAI - X")))]))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text("PROSES PEMBAYARAN"))),
        ])),
      ]),
    );
  }

  Widget _buildKeranjangPanelHP(List<CartItem> cart, int cartCount, double total){
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Keranjang $cartCount item", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:18)),
        const SizedBox(height:12),
        TextField(controller: namaPembeliCtrl, decoration: InputDecoration(hintText: "Nama Pembeli opsional", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height:8),
        DropdownButtonFormField<int>(value: topDays, decoration: InputDecoration(labelText: "TOP / Tempo", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: const [DropdownMenuItem(value:0, child:Text("0 - TUNAI Lunas")), DropdownMenuItem(value:7, child:Text("7 hari HITAM")), DropdownMenuItem(value:14, child:Text("14 hari HITAM")), DropdownMenuItem(value:30, child:Text("30 hari KUNING"))], onChanged: (v)=> setState(()=> topDays=v??0)),
        const SizedBox(height:20),
        if(cart.isEmpty) const Center(child: Padding(padding: EdgeInsets.symmetric(vertical:20), child: Text("Keranjang kosong"))) else Column(children: cart.map((it)=> ListTile(title: Text(it.barang.nama), subtitle: Text("x${it.qty}"), trailing: IconButton(icon: const Icon(Icons.close), onPressed: ()=> ref.read(cartProvider.notifier).hapusItem(it.barang.id, it.tipe)))).toList()),
        const SizedBox(height:20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text("Total"), Text(formatRp(total), style: const TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Color(0xFF059669)))]),
        const SizedBox(height:12),
        SizedBox(width: double.infinity, height:52, child: ElevatedButton(onPressed: total<=0? null: () async { final nota="INV-${DateTime.now().millisecondsSinceEpoch}"; final nama=namaPembeliCtrl.text.trim().isEmpty? "Umum": namaPembeliCtrl.text.trim(); await ref.read(cartProvider.notifier).checkout(pelangganNama: nama=="Umum"? null: nama, topDays: topDays, noNota: nota); if(!context.mounted) return; showModalBottomSheet(context: context, builder: (_)=> Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children:[const Text("Nota Preview", style: TextStyle(fontWeight: FontWeight.bold)), Text("No: $nota"), Text("Pelanggan: $nama"), ElevatedButton(onPressed: ()=> Navigator.pop(context), child: const Text("SELESAI - X"))]))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text("PROSES PEMBAYARAN"))),
      ]),
    );
  }
}
