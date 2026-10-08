import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/kasir_provider.dart';

class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});
  @override ConsumerState<KasirScreen> createState()=> _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> with SingleTickerProviderStateMixin {
  final searchCtrl = TextEditingController();
  final namaPembeliCtrl = TextEditingController();
  FilterKategoriHarga filter = FilterKategoriHarga.semua;
  int topDays = 0;
  final Map<int, TextEditingController> qtyControllers = {};

  String _currentTab = 'toko';
  final GlobalKey _notaKey = GlobalKey();
  File? _lastScreenshotFile;
  bool _isLeftMinimized = false;
  double _leftWidthFactor = 0.56; // 56% persis HTML
  final Map<int, double> manualPrices = {};
  final Map<int, TextEditingController> manualInputCtrls = {};
  final Map<int, bool> showManualInput = {};

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override void initState(){
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0)).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOutCubic, reverseCurve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _slideController, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)));
  }

  void _toggleMinimize(bool minimize){
    setState(()=> _isLeftMinimized=minimize);
    if(minimize){
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  String formatRp(double n) => "Rp ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m)=> '${m[1]}.')}";

  double marginPct(double hpp, double jual){
    if(hpp==0) return 0;
    return ((jual-hpp)/hpp*100);
  }

  @override void dispose(){
    _slideController.dispose();
    searchCtrl.dispose();
    namaPembeliCtrl.dispose();
    for(var c in qtyControllers.values) c.dispose();
    for(var c in manualInputCtrls.values) c.dispose();
    super.dispose();
  }

  void _addToCartHtml(BarangData b, TipeHarga tipe, double harga, int qty){
    ref.read(cartProvider.notifier).tambahItem(b, qty: qty, tipeHarga: tipe, hargaManual: tipe==TipeHarga.manual? harga: null);
  }

  @override Widget build(BuildContext context){
    final barangList = ref.watch(inventoryStreamProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final cartCount = cart.fold<int>(0, (s,i)=> s+i.qty);
    final produkCount = barangList.maybeWhen(data: (l)=> l.length, orElse: ()=> 0);

    // === SELALU SPLIT KIRI-KANAN, BUKAN ATAS-BAWAH ===
    // garis biru = divider vertical bisa geser
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // AppBar 56px - tanpa tombol X trash (sudah dihapus)
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Center(child: Text("SJ", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 8),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Sony Jaya - Kasir Pintar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                  Text("Toko Perkakas & Bahan Bangunan", style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)), overflow: TextOverflow.ellipsis),
                ])),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints){
                final totalW = constraints.maxWidth;
                final leftW = _isLeftMinimized? 0.0 : totalW * _leftWidthFactor;
                return Row(
                  children: [
                    // LEFT / PRODUK - 56% + ANIMASI SLIDE
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeInOutCubic,
                      width: leftW,
                      child: ClipRect(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: leftW==0? const SizedBox(): _buildProdukPanel(produkCount, barangList, true),
                          ),
                        ),
                      ),
                    ),
                    // GARIS BIRU PEMBATAS - animasi warna + geser mentok auto hide/show
                    GestureDetector(
                      onHorizontalDragStart: (_){},
                      onHorizontalDragUpdate: (d){
                        if(_isLeftMinimized && d.delta.dx>20){
                          // geser kanan dari hide -> kembali normal dengan animasi slide in
                          _toggleMinimize(false);
                          setState(()=> _leftWidthFactor=0.56);
                          return;
                        }
                        final newFactor = (_leftWidthFactor + d.delta.dx/totalW).clamp(0.0, 1.0);
                        if(newFactor < 0.15){
                          if(!_isLeftMinimized) _toggleMinimize(true);
                        } else if(newFactor > 0.85){
                          if(_isLeftMinimized) _toggleMinimize(false);
                          setState(()=> _leftWidthFactor=0.56);
                        } else {
                          setState((){
                            _leftWidthFactor=newFactor.clamp(0.28, 0.72);
                            if(_isLeftMinimized){ _isLeftMinimized=false; _slideController.reverse(); }
                          });
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeColumn,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 10,
                          color: _isLeftMinimized? const Color(0xFF3B82F6): const Color(0xFFF3F4F6),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 4,
                              height: _isLeftMinimized? 60: 40,
                              decoration: BoxDecoration(color: _isLeftMinimized? Colors.white: Colors.grey[400], borderRadius: BorderRadius.circular(999)),
                            )
                          ),
                        ),
                      ),
                    ),
                    // RIGHT / KERANJANG - animasi expand saat kiri hide
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeInOutCubic,
                        child: _buildKeranjangPanel(cart, cartCount, total, true),
                      )
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukPanel(int produkCount, AsyncValue<List<BarangData>> barangList, bool isWide){
    return Container(
      color: Colors.white,
      child: Column(
        children:[
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children:[const Text("PRODUK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)), const SizedBox(width: 6), Text("$produkCount", style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12))]),
                // Tombol X minimize - hide kiri dengan animasi slide
                InkWell(
                  onTap: ()=> _toggleMinimize(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children:[Text("Minimize kiri X", style: TextStyle(fontSize: 11)), SizedBox(width: 4), Icon(Icons.close, size: 12)]),
                  ),
                ),
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children:[
              TextField(
                controller: searchCtrl,
                onChanged: (_)=> setState((){}),
                decoration: InputDecoration(
                  hintText: "nama / sku / cari...",
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  filled:true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Colors.black, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                )
              ),
              const SizedBox(height: 10),
              Row(children: [_filterChip("Semua", FilterKategoriHarga.semua), const SizedBox(width: 8), _filterChip("Ecer", FilterKategoriHarga.ecer), const SizedBox(width: 8), _filterChip("Agen", FilterKategoriHarga.agen)]),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: Text("Filter aktif: ${filter==FilterKategoriHarga.semua?"SEMUA":filter==FilterKategoriHarga.ecer?"ECER":filter==FilterKategoriHarga.agen?"AGEN":"MARGIN"}", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontFamily: 'monospace')))),
            ])
          ),
          Expanded(child: _barangListView(barangList)),
        ]
      ),
    );
  }

  Widget _filterChip(String label, FilterKategoriHarga f){
    final sel = filter==f;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: sel? Colors.white: Colors.black)),
      selected: sel,
      selectedColor: Colors.black,
      backgroundColor: Colors.white,
      side: BorderSide(color: sel? Colors.black: const Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      onSelected: (_)=> setState(()=> filter=f)
    );
  }

  Widget _barangListView(AsyncValue<List<BarangData>> barangList){
    return barangList.when(
      data: (list){
        var filtered = list.where((b)=> searchCtrl.text.isEmpty || b.nama.toLowerCase().contains(searchCtrl.text.toLowerCase()) || (b.sku??"").toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
        if(filter==FilterKategoriHarga.marginTinggi) filtered = filtered.where((b)=> b.hppAverage>0 && ((b.hargaEcer-b.hppAverage)/b.hppAverage*100)>=30).toList();
        if(filtered.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada barang - tambah di Stok")));
        return ListView.builder(
          itemCount: filtered.length,
          padding: const EdgeInsets.all(12),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_,i){
            final b=filtered[i];
            final qtyCtrl = qtyControllers.putIfAbsent(b.id, ()=> TextEditingController(text: "1"));
            final manualCtrl = manualInputCtrls.putIfAbsent(b.id, ()=> TextEditingController());
            final isShowManual = showManualInput[b.id]??false;
            final mEcer = marginPct(b.hppAverage.toDouble(), b.hargaEcer.toDouble());
            final mAgen = marginPct(b.hppAverage.toDouble(), b.hargaAgen.toDouble());
            final manualPrice = manualPrices[b.id];
            final mManual = manualPrice!=null? marginPct(b.hppAverage.toDouble(), manualPrice):0.0;
            return Container(
              margin: const EdgeInsets.only(bottom:12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(16), color: Colors.white),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Expanded(child: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)), child: Text("Stok ${b.stok}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534))))]),
                const SizedBox(height:6),
                Row(children:[Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: Text(b.sku??"-", style: const TextStyle(fontSize: 11))), const SizedBox(width: 8), Text("HPP ${formatRp(b.hppAverage.toDouble())}", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))]),
                const SizedBox(height:12),
                Row(children:[
                  const Text("QTY", style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  const SizedBox(width: 12),
                  Container(decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: Row(children:[
                    IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: (){ final v=int.tryParse(qtyCtrl.text)??1; if(v>1) setState(()=> qtyCtrl.text="${v-1}"); }, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
                    SizedBox(width: 24, child: TextField(controller: qtyCtrl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), decoration: const InputDecoration(border: InputBorder.none, isDense:true, contentPadding: EdgeInsets.zero))),
                    IconButton(icon: const Icon(Icons.add, size: 16), onPressed: (){ final v=int.tryParse(qtyCtrl.text)??1; setState(()=> qtyCtrl.text="${v+1}"); }, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
                  ])),
                ]),
                const SizedBox(height:12),
                SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children:[
                  _ecerBtn(b, qtyCtrl, mEcer),
                  const SizedBox(width: 8),
                  _agenBtn(b, qtyCtrl, mAgen),
                  const SizedBox(width: 8),
                  _manualBtn(b, qtyCtrl, manualPrice, mManual),
                ])),
                if(isShowManual) Padding(padding: const EdgeInsets.only(top: 10), child: Row(children:[
                  Expanded(child: TextField(controller: manualCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Rp manual", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 2)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
                  const SizedBox(width: 8),
                  InkWell(onTap: (){ final val = double.tryParse(manualCtrl.text); if(val==null) return; setState((){ manualPrices[b.id]=val; showManualInput[b.id]=false; }); final q=int.tryParse(qtyCtrl.text)??1; _addToCartHtml(b, TipeHarga.manual, val, q); }, child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Center(child: Text("✔️", style: TextStyle(color: Colors.white))))),
                  const SizedBox(width: 8),
                  InkWell(onTap: ()=> setState(()=> showManualInput[b.id]=false), child: Container(width: 40, height: 40, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), shape: BoxShape.circle), child: const Center(child: Text("✖️")))),
                ])),
                const SizedBox(height:8),
                const Text("• Ecer & Agen tersedia • Manual tersedia", style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              ])
            );
          }
        );
      },
      loading: ()=> const Center(child: CircularProgressIndicator()),
      error: (e,_ )=> Center(child: Text("Error $e")),
    );
  }

  Widget _ecerBtn(BarangData b, TextEditingController qtyCtrl, double m){
    return InkWell(onTap: (){ final q=int.tryParse(qtyCtrl.text)??1; _addToCartHtml(b, TipeHarga.ecer, b.hargaEcer.toDouble(), q); }, child: Container(constraints: const BoxConstraints(minWidth: 120), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), border: Border.all(color: const Color(0xFFBFDBFE)), borderRadius: BorderRadius.circular(999)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("ECER ${formatRp(b.hargaEcer.toDouble())}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text("+${m.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)))])));
  }
  Widget _agenBtn(BarangData b, TextEditingController qtyCtrl, double m){
    return InkWell(onTap: (){ final q=int.tryParse(qtyCtrl.text)??1; _addToCartHtml(b, TipeHarga.agen, b.hargaAgen.toDouble(), q); }, child: Container(constraints: const BoxConstraints(minWidth: 120), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), border: Border.all(color: const Color(0xFFFDE68A)), borderRadius: BorderRadius.circular(999)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("AGEN ${formatRp(b.hargaAgen.toDouble())}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text("+${m.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)))])));
  }
  Widget _manualBtn(BarangData b, TextEditingController qtyCtrl, double? manualPrice, double mManual){
    return GestureDetector(
      onTap: (){ if(manualPrice!=null){ final q=int.tryParse(qtyCtrl.text)??1; _addToCartHtml(b, TipeHarga.manual, manualPrice, q); } else { setState(()=> showManualInput[b.id]=true); } },
      onLongPress: ()=> setState(()=> showManualInput[b.id]=true),
      child: Container(constraints: const BoxConstraints(minWidth: 132), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: manualPrice==null? const Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("MANUAL ✏️", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text("Tap nambah, tahan ganti", style: TextStyle(fontSize: 9, color: Color(0xFF6B7280)))]): Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("MANUAL ${""}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text("MANUAL ${formatRp(manualPrice)}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text("${mManual>=0?'+':''}${mManual.toStringAsFixed(0)}%", style: TextStyle(fontSize: 11, color: mManual>=0? Color(0xFF16A34A): Colors.red))])),
    );
  }

  Widget _barangListViewHP(AsyncValue<List<BarangData>> barangList){
    // HP juga pakai layout yang sama kiri-kanan, bukan atas-bawah
    return _barangListView(barangList);
  }

  Widget _buildKeranjangPanel(List<CartItem> cart, int cartCount, double total, bool isWide){
    return Container(
      color: Colors.white,
      child: Column(
        children:[
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children:[const Text("KERANJANG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(999))), child: Text("$cartCount", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))]),
                Row(children:[
                  if(_isLeftMinimized)
                    InkWell(
                      onTap: (){
                        _toggleMinimize(false);
                        setState(()=> _leftWidthFactor=0.56);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(999)),
                        child: const Row(children:[Icon(Icons.visibility, size: 12, color: Colors.white), SizedBox(width: 4), Text("Produk ↗", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))]),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if(cart.isNotEmpty) InkWell(onTap: ()=> ref.read(cartProvider.notifier).clearCart(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: const Text("🗑 Kosongkan", style: TextStyle(fontSize: 11)))),
                ]),
              ]
            ),
          ),
          Expanded(
            child: cart.isEmpty? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
              Icon(Icons.shopping_cart_outlined, size: 40, color: Color(0xFF9CA3AF)),
              SizedBox(height: 8),
              Text("Keranjang kosong", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Tap ECER atau AGEN pada produk kiri untuk menambah", style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
            ])): ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.length,
              itemBuilder: (_,i){
                final it=cart[i];
                final sku = it.barang.sku??"-";
                final tipeLabel = it.tipe==TipeHarga.ecer?"ECER": it.tipe==TipeHarga.agen?"AGEN":"MANUAL";
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                      Text(it.barang.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children:[
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(999)), child: Text(tipeLabel, style: const TextStyle(fontSize: 10))),
                        const SizedBox(width: 6),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: Text(sku, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)))),
                      ]),
                      const SizedBox(height: 6),
                      Row(children:[
                        InkWell(onTap: (){ if(it.qty>1) ref.read(cartProvider.notifier).updateQty(it.barang.id, it.tipe, it.qty-1, hargaJual: it.hargaJual); }, child: Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), shape: BoxShape.circle), child: const Icon(Icons.remove, size: 14))),
                        SizedBox(width: 28, child: Center(child: Text("${it.qty}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))),
                        InkWell(onTap: ()=> ref.read(cartProvider.notifier).updateQty(it.barang.id, it.tipe, it.qty+1, hargaJual: it.hargaJual), child: Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), shape: BoxShape.circle), child: const Icon(Icons.add, size: 14))),
                        const SizedBox(width: 8),
                        Text(formatRp(it.hargaJual), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ]),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
                      Text(formatRp(it.qty*it.hargaJual), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      InkWell(onTap: ()=> ref.read(cartProvider.notifier).hapusItem(it.barang.id, it.tipe, hargaJual: it.hargaJual), child: Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), shape: BoxShape.circle), child: const Icon(Icons.close, size: 14))),
                    ]),
                  ])
                );
              }
            )
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
            child: Column(children:[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Text("Total (${cart.fold(0, (s,e)=> s+e.qty)} item)", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)), Text(formatRp(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: total<=0? null: () async {
                final nota="INV-${DateTime.now().millisecondsSinceEpoch}";
                final nama=namaPembeliCtrl.text.trim().isEmpty? "Umum": namaPembeliCtrl.text.trim();
                _showStrukSuratModal(context, cart, total, nota, nama);
              }, style: ElevatedButton.styleFrom(backgroundColor: total<=0? const Color(0xFFE5E7EB): const Color(0xFF2563EB), foregroundColor: total<=0? const Color(0xFF9CA3AF): Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))), child: const Text("PROSES PEMBAYARAN", style: TextStyle(fontWeight: FontWeight.bold)))),
              const SizedBox(height: 8),
              const Text("Geser garis biru tengah untuk atur lebar • Mentok kiri auto hide • Mentok kanan kembali normal", style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
            ])
          ),
        ]
      ),
    );
  }

  Widget _buildKeranjangPanelHP(List<CartItem> cart, int cartCount, double total){
    return _buildKeranjangPanel(cart, cartCount, total, false);
  }

  void _showStrukSuratModal(BuildContext context, List<CartItem> cart, double total, String nota, String nama){
    showDialog(context: context, barrierColor: Colors.black.withOpacity(0.6), builder: (_){
      return StatefulBuilder(builder: (ctx, setModal){
        return Dialog(insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 70), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Container(constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children:[
          Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
            Row(children:[const Text("Struk & Surat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(999))), child: Text("${cart.length} item", style: const TextStyle(color: Colors.white, fontSize: 11)))]),
            InkWell(onTap: ()=> Navigator.pop(ctx), child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle), child: const Icon(Icons.close, size: 18))),
          ])),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            TextField(controller: namaPembeliCtrl, onChanged: (_)=> setModal((){}), decoration: InputDecoration(hintText: "Nama Pelanggan - kosongkan jika Umum", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: Color(0xFFE5E7EB))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), isDense: true)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), border: Border.all(color: const Color(0xFFBBF7D0)), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
              const Row(children:[Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)), SizedBox(width: 8), Text("Preview nota putih - siap screenshot", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF166534)))]),
              InkWell(onTap: () async { await _captureNota(ctx); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(999)), child: const Text("📷 Screenshot Nota", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
            ])),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children:[
              _tabBtn("Struk Toko", _currentTab=='toko', ()=> setModal(()=> _currentTab='toko')),
              _tabBtn("Struk Pelanggan", _currentTab=='pelanggan', ()=> setModal(()=> _currentTab='pelanggan')),
              _tabBtn("Surat Jalan", _currentTab=='surat', ()=> setModal(()=> _currentTab='surat')),
            ])),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))), child: RepaintBoundary(key: _notaKey, child: Container(padding: const EdgeInsets.fromLTRB(28, 24, 28, 24), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5), borderRadius: BorderRadius.circular(14)), child: Column(children:[
              const Text("SONY JAYA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
              const Text("Kasir Pintar", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              const Text("Jl Mawar No 12, Jakarta\nTel: 0812-3456-7890", style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.grey[300], child: CustomPaint(painter: _DashedLinePainter())),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Text("${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))), Text("${DateTime.now().hour}.${DateTime.now().minute.toString().padLeft(2,'0')} WIB", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))]),
              const SizedBox(height: 12),
              ...cart.map((it){
                final sku = it.barang.sku??"-";
                final qty = it.qty;
                final price = it.hargaJual;
                final sub = qty*price;
                final tipeLabel = it.tipe==TipeHarga.ecer?"ECER":it.tipe==TipeHarga.agen?"AGEN":"MANUAL";
                if(_currentTab=='toko'){
                  return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("${it.barang.nama} - $sku", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2)), const SizedBox(height: 2), Text("$qty x ${formatRp(price)} [$tipeLabel]", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.2))])), Text(formatRp(sub), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
                } else if(_currentTab=='pelanggan'){
                  return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(it.barang.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2)), const SizedBox(height: 2), Text("$qty x ${formatRp(price)}", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.2))])), Text(formatRp(sub), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
                } else {
                  return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("${it.barang.nama} - $sku", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2)), const SizedBox(height: 2), Text("$qty pcs", style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.2))])), Text("$qty pcs", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
                }
              }),
              const SizedBox(height: 8),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(_currentTab=='surat'? "${cart.fold(0, (s,e)=> s+e.qty)} pcs": formatRp(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.grey[300], child: CustomPaint(painter: _DashedLinePainter())),
              const SizedBox(height: 12),
              const Text("Terima kasih telah berbelanja di Sony Jaya 🙏\nBarang tidak dapat dikembalikan", style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(_currentTab=='toko'? "COPY TOKO": _currentTab=='pelanggan'? "COPY PELANGGAN": "SURAT JALAN", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13)),
            ])))),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Row(children:[Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFACC15), shape: BoxShape.circle)), const SizedBox(width: 8), Text(_currentTab=='toko'? "Struk Toko": _currentTab=='pelanggan'? "Struk Pelanggan": "Surat Jalan", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))]), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(999)), child: const Text("bluetooth", style: TextStyle(color: Colors.white70, fontSize: 9)))]),
              const SizedBox(height: 8),
              Text(_buildWaText(cart, total, nama), style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace', height: 1.35)),
            ])),
          ]))),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))), child: Row(children:[
            Expanded(child: InkWell(onTap: () async { final waText = _buildWaText(cart, total, nama); await _shareWa(waText); }, child: Container(height: 48, decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(999)), child: const Center(child: Text("↗ Share WA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))))),
            const SizedBox(width: 12),
            Expanded(child: InkWell(onTap: () async { final checkoutNama = namaPembeliCtrl.text.trim().isEmpty? null: namaPembeliCtrl.text.trim(); await ref.read(cartProvider.notifier).checkout(pelangganNama: checkoutNama, topDays: topDays, noNota: nota); if(context.mounted) Navigator.pop(ctx); }, child: Container(height: 48, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(999)), child: const Center(child: Text("Tutup & Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))))),
          ])),
        ]));
      });
    });
  }

  Widget _tabBtn(String label, bool selected, VoidCallback onTap){
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: selected? Colors.black: Colors.transparent, borderRadius: BorderRadius.circular(999)), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected? Colors.white: const Color(0xFF6B7280)))));
  }

  String _buildWaText(List<CartItem> cart, double total, String nama){
    final date = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}.${DateTime.now().minute.toString().padLeft(2,'0')} WIB";
    if(_currentTab=='toko'){
      var wa = "SONY JAYA - STRUK TOKO\nJl Mawar No 12, Jakarta\n---------------------------\nPelanggan: $nama\nTanggal: $date\n---------------------------\n";
      for(var c in cart){ wa += "${c.barang.nama} ${c.barang.sku??''} (${c.tipe==TipeHarga.ecer?"ECER":c.tipe==TipeHarga.agen?"AGEN":"MANUAL"}) ${c.qty} x ${formatRp(c.hargaJual)} = ${formatRp(c.qty*c.hargaJual)}\n"; }
      wa += "---------------------------\nTOTAL: ${formatRp(total)}\nTerima kasih 🙏";
      return wa;
    } else if(_currentTab=='pelanggan'){
      var wa = "SONY JAYA - STRUK PELANGGAN\n---------------------------\n";
      for(var c in cart){ wa += "${c.barang.nama} ${c.qty} x ${formatRp(c.hargaJual)} = ${formatRp(c.qty*c.hargaJual)}\n"; }
      wa += "---------------------------\nTOTAL: ${formatRp(total)}";
      return wa;
    } else {
      var wa = "SONY JAYA - SURAT JALAN\n---------------------------\n";
      for(var c in cart){ wa += "${c.barang.nama} ${c.barang.sku??''} ${c.qty} pcs\n"; }
      wa += "---------------------------\nTOTAL QTY: ${cart.fold(0, (s,e)=> s+e.qty)} pcs";
      return wa;
    }
  }

  Future<void> _captureNota(BuildContext ctx) async {
    try{
      final boundary = _notaKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/nota_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      _lastScreenshotFile = file;
      _showPreviewNota(ctx, file);
    }catch(e){ debugPrint("capture error $e"); }
  }

  void _showPreviewNota(BuildContext ctx, File file){
    showDialog(context: ctx, barrierColor: Colors.black.withOpacity(0.7), builder: (dialogCtx){
      return Dialog(insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Container(constraints: const BoxConstraints(maxWidth: 380, maxHeight: 600), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children:[
        Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
          const Text("📷 Preview Nota", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          InkWell(onTap: ()=> Navigator.pop(dialogCtx), child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle), child: const Icon(Icons.close, size: 18))),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: Column(children:[
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, fit: BoxFit.contain, width: double.infinity))),
          const SizedBox(height: 12),
          const Text("Geser atas-bawah untuk lihat nota panjang", style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
        ]))),
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))), child: Row(children:[
          Expanded(child: InkWell(onTap: ()=> Navigator.pop(dialogCtx), child: Container(height: 48, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(999)), child: const Center(child: Text("Tutup", style: TextStyle(fontWeight: FontWeight.w500)))))),
          const SizedBox(width: 12),
          Expanded(child: InkWell(onTap: () async { final cart = ref.read(cartProvider); final total = ref.read(cartTotalProvider); final waText = _buildWaText(cart, total, namaPembeliCtrl.text.trim().isEmpty? "Umum": namaPembeliCtrl.text.trim()); await _shareWaWithImage(file, waText); }, child: Container(height: 48, decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(999)), child: const Center(child: Text("↗ Share WA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
        ])),
      ])));
    });
  }

  Future<void> _shareWa(String text) async { await Share.share(text); }
  Future<void> _shareWaWithImage(File file, String text) async {
    try{ await Share.shareXFiles([XFile(file.path)], text: text); }catch(_){ await Share.share(text); }
  }
}

class _DashedLinePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size){
    final paint = Paint()..color = const Color(0xFFD1D5DB)..strokeWidth = 1..style = PaintingStyle.stroke;
    const dashWidth = 6.0; const dashSpace = 4.0; double startX = 0;
    while(startX < size.width){ canvas.drawLine(Offset(startX, 0), Offset(startX+dashWidth, 0), paint); startX += dashWidth + dashSpace; }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=> false;
}
