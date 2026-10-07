import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

enum TipeHarga { ecer, agen, manual }
enum FilterKategoriHarga { semua, ecer, agen, marginTinggi }

class CartItem {
  final BarangData barang;
  final int qty;
  final double hargaJual;
  final TipeHarga tipe;
  CartItem({required this.barang, required this.qty, required this.hargaJual, required this.tipe});

  CartItem copyWith({BarangData? barang, int? qty, double? hargaJual, TipeHarga? tipe}){
    return CartItem(
      barang: barang ?? this.barang,
      qty: qty ?? this.qty,
      hargaJual: hargaJual ?? this.hargaJual,
      tipe: tipe ?? this.tipe,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override List<CartItem> build() => [];

  // === FIX: support manual + merge by id+tipe+harga (persis HTML) ===
  void tambahItem(BarangData barang, {int qty=1, required TipeHarga tipeHarga, double? hargaManual}) {
    double harga;
    if(tipeHarga==TipeHarga.manual){
      if(hargaManual==null) throw Exception('Harga manual wajib diisi');
      harga = hargaManual;
    } else if(tipeHarga==TipeHarga.ecer){
      harga = barang.hargaEcer.toDouble();
    } else {
      harga = barang.hargaAgen.toDouble();
    }

    // MARGIN GUARD hanya untuk ecer/agen, manual boleh bebas (sesuai HTML)
    if(tipeHarga!=TipeHarga.manual && harga < barang.hppAverage && barang.hppAverage>0){
      throw Exception('MARGIN GUARD: Harga di bawah HPP!');
    }
    if(qty > barang.stok) throw Exception('Stok tidak cukup! Sisa ${barang.stok}');

    // Merge logic persis HTML: cari id+tipe+harga sama -> qty+=, bukan push baru
    final idx = state.indexWhere((e)=> e.barang.id==barang.id && e.tipe==tipeHarga && (e.hargaJual - harga).abs() < 0.01);
    if(idx>=0){
      final exist = state[idx];
      final newQty = exist.qty + qty;
      if(newQty > barang.stok) throw Exception('Stok tidak cukup! Sisa ${barang.stok}');
      state = [for(int i=0;i<state.length;i++) if(i==idx) exist.copyWith(qty: newQty, hargaJual: harga) else state[i]];
    } else {
      // cek stok total untuk barang yang sama (semua tipe)
      final totalQtyBarang = state.where((e)=> e.barang.id==barang.id).fold(0, (s,e)=> s+e.qty) + qty;
      if(totalQtyBarang > barang.stok) throw Exception('Stok tidak cukup! Total keranjang untuk ${barang.nama} melebihi stok');
      state = [...state, CartItem(barang: barang, qty: qty, hargaJual: harga, tipe: tipeHarga)];
    }
  }

  void updateQty(int barangId, TipeHarga tipe, int newQty, {double? hargaJual}) {
    final idx = hargaJual==null
        ? state.indexWhere((e)=> e.barang.id==barangId && e.tipe==tipe)
        : state.indexWhere((e)=> e.barang.id==barangId && e.tipe==tipe && (e.hargaJual - hargaJual).abs() < 0.01);
    if(idx==-1) return;
    if(newQty<=0){
      hapusItem(barangId, tipe, hargaJual: hargaJual);
      return;
    }
    final exist = state[idx];
    if(newQty > exist.barang.stok) throw Exception('Stok tidak cukup! Sisa ${exist.barang.stok}');
    state = [for(int i=0;i<state.length;i++) if(i==idx) exist.copyWith(qty: newQty) else state[i]];
  }

  void hapusItem(int barangId, TipeHarga tipe, {double? hargaJual}) {
    if(hargaJual==null){
      state = state.where((e)=>!(e.barang.id==barangId && e.tipe==tipe)).toList();
    } else {
      state = state.where((e)=>!(e.barang.id==barangId && e.tipe==tipe && (e.hargaJual - hargaJual).abs() < 0.01)).toList();
    }
  }

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
          tipe: c.tipe==TipeHarga.ecer? 'eceran_kasir' : c.tipe==TipeHarga.agen? 'agen_kasir' : 'manual_kasir',
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
