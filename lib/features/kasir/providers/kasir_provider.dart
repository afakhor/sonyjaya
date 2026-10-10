// lib/features/kasir/providers/kasir_provider.dart - FINAL FIX FULL - tanpa kurangi logika, tambah fitur manual, updateQty, searchQuery
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// FIX: enum tambah manual biar kasir_screen TipeHarga.manual ketemu
enum TipeHarga { ecer, agen, manual }

class CartItem {
  final BarangData barang;
  final int qty;
  final double hargaJual;
  final TipeHarga tipe;
  CartItem({required this.barang, required this.qty, required this.hargaJual, required this.tipe});
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override List<CartItem> build() => [];

  // FIX: tambah param hargaManual optional biar kasir_screen tidak error, logic tetap margin guard + stok
  void tambahItem(BarangData barang, {int qty=1, required TipeHarga tipeHarga, double? hargaManual}) {
    double harga;
    if(tipeHarga==TipeHarga.manual && hargaManual!=null){
      harga = hargaManual;
    } else {
      harga = tipeHarga==TipeHarga.ecer? barang.hargaEcer : (tipeHarga==TipeHarga.agen? barang.hargaAgen : (hargaManual ?? barang.hargaEcer));
    }
    if(harga < barang.hppAverage && barang.hppAverage>0) throw Exception('MARGIN GUARD: Harga Rp ${harga.toStringAsFixed(0)} di bawah HPP Rp ${barang.hppAverage.toStringAsFixed(0)}!');
    if(qty > barang.stok) throw Exception('Stok tidak cukup! Sisa ${barang.stok}');
    final idx = state.indexWhere((e)=> e.barang.id==barang.id && e.tipe==tipeHarga && e.hargaJual==harga);
    if(idx>=0){
      final exist = state[idx];
      final newQty = exist.qty + qty;
      if(newQty > barang.stok) throw Exception('Stok tidak cukup! Sisa ${barang.stok}');
      state = [for(int i=0;i<state.length;i++) if(i==idx) CartItem(barang: barang, qty: newQty, hargaJual: harga, tipe: tipeHarga) else state[i]];
    } else {
      state = [...state, CartItem(barang: barang, qty: qty, hargaJual: harga, tipe: tipeHarga)];
    }
  }

  // FIX: tambah updateQty biar kasir_screen bisa +/-
  void updateQty(int barangId, TipeHarga tipe, int newQty, {double? hargaJual}) {
    if(newQty<=0){ hapusItem(barangId, tipe, hargaJual: hargaJual); return; }
    state = state.map((e){
      if(e.barang.id==barangId && e.tipe==tipe && (hargaJual==null || e.hargaJual==hargaJual)){
        if(newQty > e.barang.stok) throw Exception('Stok tidak cukup! Sisa ${e.barang.stok}');
        return CartItem(barang: e.barang, qty: newQty, hargaJual: e.hargaJual, tipe: e.tipe);
      }
      return e;
    }).toList();
  }

  // FIX: hapusItem support hargaJual optional biar kasir_screen tidak error
  void hapusItem(int barangId, TipeHarga tipe, {double? hargaJual}) {
    state = state.where((e)=> !(e.barang.id==barangId && e.tipe==tipe && (hargaJual==null || e.hargaJual==hargaJual))).toList();
  }
  void clearCart() => state = [];

  Future<void> checkout({String? pelangganNama, int topDays=0, String? noNota}) async {
    if(state.isEmpty) return;
    final db = ref.read(localDbProvider);
    final inv = ref.read(inventoryControllerProvider);
    await db.transaction(() async {
      double grandTotal = 0;
      for(var c in state){ grandTotal += c.qty * c.hargaJual; }
      final String finalNoNota = noNota ?? 'INV-${DateTime.now().millisecondsSinceEpoch}';
      final items = state.map((c)=> {
        'barangId': c.barang.id,
        'qty': c.qty,
        'harga': c.hargaJual,
        'tipe': c.tipe==TipeHarga.ecer? 'eceran_kasir' : (c.tipe==TipeHarga.agen? 'agen_kasir' : 'manual_kasir'),
      }).toList();
      await db.transaksiDao.prosesPenjualan(items: items, noNota: finalNoNota);

      if(pelangganNama!=null && pelangganNama.isNotEmpty && topDays>0){
        final jatuhTempo = DateTime.now().add(Duration(days: topDays));
        // FIX: Value<> wrapper
        await db.piutangDao.createPiutang(PelangganPiutangCompanion.insert(
          noNota: finalNoNota,
          pelangganNama: pelangganNama,
          totalTagihan: grandTotal,
          sisaPiutang: grandTotal,
          topDays: Value(topDays),
          jatuhTempo: Value(jatuhTempo),
          tanggalNota: Value(DateTime.now()),
        ));
        int totalQty = state.fold(0, (sum, e)=> sum + e.qty);
        await db.pelangganMasterDao.upsertAndRating(nama: pelangganNama, totalBelanja: grandTotal, qty: totalQty, variasi: state.length);
      }
      for(var c in state){ await inv.refreshCacheAfterCheckout(c.barang.id); }
    });
    clearCart();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
final cartTotalProvider = Provider<double>((ref){
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, e)=> sum + e.qty * e.hargaJual);
});

// FIX: StateProvider tidak ada di Riverpod 3 -> ganti Notifier
class SearchQueryNotifier extends Notifier<String> {
  @override String build() => '';
  void set(String v) => state = v;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

enum FilterKategoriHarga { semua, ecer, agen, marginTinggi }
