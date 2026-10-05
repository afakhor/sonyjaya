import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/kasir_provider.dart';
// import provider pelanggan kamu, sesuaikan namanya
// import '../pelanggan/providers/pelanggan_provider.dart';

class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});
  @override ConsumerState<KasirScreen> createState()=> _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  final searchCtrl = TextEditingController();
  FilterKategoriHarga filter = FilterKategoriHarga.semua;
  final Map<int, TextEditingController> qtyControllers = {};

  double leftFlex = 65;
  double rightFlex = 35;
  bool isLeftMinimized = false;
  double _lastLeftFlex = 65;

  // DUMMY DIHAPUS - tidak ada lagi pelangganSuggestions

  @override void dispose(){
    searchCtrl.dispose();
    for(var c in qtyControllers.values) c.dispose();
    super.dispose();
  }

  void _toggleMinimizeKiri(){
    setState((){
      if(isLeftMinimized){
        leftFlex = _lastLeftFlex;
        rightFlex = 100 - _lastLeftFlex;
        isLeftMinimized = false;
      } else {
        _lastLeftFlex = leftFlex;
        leftFlex = 0;
        rightFlex = 100;
        isLeftMinimized = true;
      }
    });
  }

  void _onDividerDrag(DragUpdateDetails details, double maxWidth){
    if(isLeftMinimized) return;
    setState((){
      final delta = details.delta.dx / maxWidth * 100;
      leftFlex = (leftFlex + delta).clamp(25, 75);
      rightFlex = 100 - leftFlex;
    });
  }

  Future<void> _showReceiptDialog(BuildContext context, List<CartItem> cart, double total) async {
    final namaCtrl = TextEditingController();
    String namaPembeli = '';

    // AMBIL DATA ASLI PELANGGAN DARI DATABASE (bukan dummy)
    // Ganti pelangganStreamProvider dengan provider kamu yang asli
    // Jika belum ada tabel pelanggan, biarkan list kosong, logika autocomplete tetap jalan
    final pelangganAsync = ref.read(pelangganStreamProvider); // atau ref.read(pelangganProvider)
    final List<String> namaPelangganReal = pelangganAsync.when(
      data: (list) => list.map((p) => p.nama as String).toList(),
      loading: () => [],
      error: (_,__) => [],
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx){
        return StatefulBuilder(
          builder: (ctx, setDialogState){
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(16),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                    const Text('Struk Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize:16)),
                    IconButton(onPressed: ()=> Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                  ]),
                  const Divider(),
                  const Text('Nama Pembeli (opsional)', style: TextStyle(fontSize:11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                  const SizedBox(height:6),

                  // LOGIKA AUTO SUGGESTIONS TETAP, DUMMY HILANG
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue){
                      if(textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                      // Filter dari data REAL, bukan dummy
                      return namaPelangganReal.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (selection){
                      namaCtrl.text = selection;
                      setDialogState(()=> namaPembeli = selection);
                    },
                    fieldViewBuilder: (context, ctrl, focusNode, onFieldSubmitted){
                      // sinkronisasi agar preview live tetap jalan
                      if(ctrl.text != namaCtrl.text && focusNode.hasFocus == false){
                        // jangan override saat user ketik
                      }
                      return TextField(
                        controller: ctrl,
                        focusNode: focusNode,
                        onChanged: (val){
                          namaCtrl.text = val;
                          setDialogState(()=> namaPembeli = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Ketik nama pembeli',
                          prefixIcon: const Icon(Icons.person_outline, size:18),
                          filled: true, fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          contentPadding: const EdgeInsets.symmetric(vertical:10),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height:16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                      const Text('Sony Jaya', style: TextStyle(fontWeight: FontWeight.w800, fontSize:13)),
                      const SizedBox(height:4),
                      if(namaPembeli.trim().isNotEmpty)
                        Text('Pelanggan: $namaPembeli', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600)),
                      const Divider(height:16),
                      ...cart.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom:6),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                          Expanded(child: Text('${it.barang.nama} x${it.qty}', style: const TextStyle(fontSize:12))),
                          Text('Rp ${(it.qty*it.hargaJual).toStringAsFixed(0)}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w700)),
                        ]),
                      )),
                      const Divider(height:16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize:13)),
                        Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize:15)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height:16),
                  SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
                    onPressed: (){
                      final buf = StringBuffer();
                      if(namaPembeli.trim().isNotEmpty) buf.writeln('Pelanggan: $namaPembeli');
                      for(var it in cart) buf.writeln('${it.barang.nama} x${it.qty} = Rp ${(it.qty*it.hargaJual).toStringAsFixed(0)}');
                      buf.writeln('Total: Rp ${total.toStringAsFixed(0)}');
                      final waText = Uri.encodeComponent(buf.toString());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share WA: $waText'), backgroundColor: Colors.green));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.share_rounded, size:18),
                    label: const Text('Share Receipt by WA', style: TextStyle(fontWeight: FontWeight.w700)),
                  )),
                  const SizedBox(height:8),
                  SizedBox(width: double.infinity, height: 48, child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(cartProvider.notifier).checkout(namaPelanggan: namaPembeli.trim().isEmpty ? null : namaPembeli);
                      if(context.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Tutup & Selesai'),
                  )),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  @override Widget build(BuildContext context){
    final barangList = ref.watch(inventoryStreamProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Sony Jaya - Kasir Pintar', style: TextStyle(fontWeight: FontWeight.w700, fontSize:18, color: Colors.black)),
        actions: [
          if(searchCtrl.text.isNotEmpty || filter!=FilterKategoriHarga.semua)
            IconButton(onPressed: ()=> setState((){ searchCtrl.clear(); filter=FilterKategoriHarga.semua; }), icon: const Icon(Icons.delete_sweep_rounded, color: Colors.black87)),
          const SizedBox(width:8),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints){
        return Row(children:[
          if(!isLeftMinimized) Expanded(flex: leftFlex.toInt(), child: Container(color: Colors.white, child: Column(children:[
            Padding(padding: const EdgeInsets.fromLTRB(16,12,8,0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
              const Text('Produk', style: TextStyle(fontWeight: FontWeight.w700, fontSize:13)),
              IconButton(tooltip: 'Minimize sisi kiri', onPressed: _toggleMinimizeKiri, icon: const Icon(Icons.close_rounded, size:20), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6))),
            ])),
            // ... search, filter chips, ListView produk kamu tetap sama (hanya 2 tombol ECER/AGEN) ...
            // copy bagian ListView dari file sebelumnya, tidak ada dummy di sini
            Expanded(child: barangList.when(
              data: (list){
                var filtered = list.where((b)=> searchCtrl.text.isEmpty || b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
                return ListView.builder(itemCount: filtered.length, padding: const EdgeInsets.fromLTRB(16,8,16,100), itemBuilder: (_,i){
                  final b=filtered[i];
                  final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: '1'));
                  return Container(
                    margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                      Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize:15)),
                      const SizedBox(height:10),
                      Row(children:[
                        Expanded(child: SizedBox(height:48, child: ElevatedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.ecer); }, child: const Text('ECER')))),
                        const SizedBox(width:8),
                        Expanded(child: SizedBox(height:48, child: OutlinedButton(onPressed: (){ final qty=int.tryParse(qtyCtrl.text)??1; ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: TipeHarga.agen); }, child: const Text('AGEN')))),
                      ]),
                    ]),
                  );
                });
              },
              loading: ()=> const Center(child: CircularProgressIndicator()),
              error: (e,_ )=> Center(child: Text('Error $e')),
            )),
          ]))),
          if(!isLeftMinimized) GestureDetector(
            onPanUpdate: (d)=> _onDividerDrag(d, constraints.maxWidth),
            child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: Container(width:12, color: const Color(0xFFF3F4F6), child: Center(child: Container(width:4, height:32, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(4)))))),
          ),
          Expanded(flex: rightFlex.toInt(), child: Container(color: const Color(0xFFF9FAFB), child: Column(children:[
            Container(padding: const EdgeInsets.all(16), color: Colors.white, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
              Row(children:[
                if(isLeftMinimized) IconButton(onPressed: _toggleMinimizeKiri, icon: const Icon(Icons.chevron_right_rounded), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6))),
                const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w700, fontSize:14)),
              ]),
              Text('${cart.length} item'),
            ])),
            Expanded(child: cart.isEmpty? const Center(child: Text('Keranjang kosong')) : ListView.builder(itemCount: cart.length, padding: const EdgeInsets.all(12), itemBuilder: (_,i){ final it=cart[i]; return ListTile(title: Text(it.barang.nama), subtitle: Text('x${it.qty}'), trailing: Text('Rp ${(it.qty*it.hargaJual).toStringAsFixed(0)}')); })),
            Container(padding: const EdgeInsets.all(16), color: Colors.white, child: Column(children:[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Total:'), Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize:20))]),
              const SizedBox(height:12),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: total<=0? null: ()=> _showReceiptDialog(context, cart, total), child: const Text('PROSES PEMBAYARAN'))),
            ])),
          ]))),
        ]);
      }),
    );
  }
}