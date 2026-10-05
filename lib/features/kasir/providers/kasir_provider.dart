import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

enum TipeHarga { ecer, agen }

class CartItem {
  final BarangData barang;
  final int qty;
  final double hargaJual;
  final TipeHarga tipe;
  CartItem({required this.barang, required this.qty, required this.hargaJual, required this.tipe});
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override List<CartItem> build() => [];

  void tambahItem(BarangData barang, {int qty=1, required TipeHarga tipeHarga}) {
    final harga = tipeHarga==TipeHarga.ecer? barang.hargaEcer : barang.hargaAgen;
    if(harga < barang.hppAverage && barang.hppAverage>0) throw Exception('MARGIN GUARD: Harga Rp ${harga.toStringAsFixed(0)} di bawah HPP Rp ${barang.hppAverage.toStringAsFixed(0)}!');
    if(qty > barang.stok) throw Exception('Stok tidak cukup! Sisa ${barang.stok}');
    final idx = state.indexWhere((e)=> e.barang.id==barang.id && e.tipe==tipeHarga);
    if(idx>=0){
      final exist = state[idx];
      final newQty = exist.qty + qty;
      if(newQty > barang.stok) throw Exception('Stok tidak cukup! Sisa ${barang.stok}');
      state = [for(int i=0;i<state.length;i++) if(i==idx) CartItem(barang: barang, qty: newQty, hargaJual: harga, tipe: tipeHarga) else state[i]];
    } else {
      state = [...state, CartItem(barang: barang, qty: qty, hargaJual: harga, tipe: tipeHarga)];
    }
  }

  void hapusItem(int barangId, TipeHarga tipe) => state = state.where((e)=>!(e.barang.id==barangId && e.tipe==tipe)).toList();
  void clearCart() => state = [];

  Future<void> checkout({String? pelangganNama, int topDays=0, String? noNota}) async {
    if(state.isEmpty) return;
    final db = ref.read(localDbProvider);
    await db.transaction(() async {
      double grandTotal = 0;
      for(var c in state){ grandTotal += c.qty * c.hargaJual; }
      for(var c in state){
        await db.transaksiDao.prosesPenjualan(
          barangId: c.barang.id,
          qtyInput: c.qty,
          hargaJualPerSatuanInput: c.hargaJual,
          tipe: c.tipe==TipeHarga.ecer? 'eceran_kasir' : 'agen_kasir',
          isSatuanBesar: false,
        );
      }
      if(pelangganNama!=null && pelangganNama.isNotEmpty && topDays>0){
        final jatuhTempo = DateTime.now().add(Duration(days: topDays));
        final nota = noNota?? 'INV-${DateTime.now().millisecondsSinceEpoch}';
        await db.piutangDao.createPiutang(
          pelangganNama: pelangganNama,
          total: grandTotal,
          topDays: topDays,
          jatuhTempo: jatuhTempo,
          noNota: nota,
          keterangan: '${state.length} item, TOP $topDays hari',
        );
        int totalQty = state.fold(0, (sum, e)=> sum + e.qty);
        await db.pelangganMasterDao.upsertAndRating(
          nama: pelangganNama,
          tambahBelanja: grandTotal,
          tambahVariasi: state.length,
          tambahQty: totalQty,
        );
      }
      final inv = ref.read(inventoryControllerProvider);
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
final searchQueryProvider = StateProvider<String>((ref)=> '');
enum FilterKategoriHarga { semua, ecer, agen, marginTinggi }
