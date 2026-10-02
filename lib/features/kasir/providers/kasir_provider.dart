import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

class CartItem {
  final BarangData barang;
  int qty;
  double hargaJual;

  CartItem({
    required this.barang,
    this.qty = 1,
    required this.hargaJual,
  });

  double get subtotal => qty * hargaJual;
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void tambahItem(BarangData barang, {int qty = 1, double? customHarga}) {
    final harga = customHarga ?? barang.hargaEcer;

    // MARGIN GUARD: Cegah jual di bawah HPP
    if (harga < barang.hppAverage) {
      throw Exception('MARGIN GUARD: Harga jual di bawah HPP (${barang.hppAverage})!');
    }

    final index = state.indexWhere((item) => item.barang.id == barang.id);
    if (index >= 0) {
      final existing = state[index];
      if (existing.qty + qty > barang.stok) {
        throw Exception('Stok tidak mencukupi! Sisa stok: ${barang.stok}');
      }
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItem(barang: barang, qty: existing.qty + qty, hargaJual: harga)
          else
            state[i]
      ];
    } else {
      if (qty > barang.stok) {
        throw Exception('Stok tidak mencukupi! Sisa stok: ${barang.stok}');
      }
      state = [...state, CartItem(barang: barang, qty: qty, hargaJual: harga)];
    }
  }

  void hapusItem(int barangId) {
    state = state.where((item) => item.barang.id != barangId).toList();
  }

  void clearCart() {
    state = [];
  }

  Future<void> checkout() async {
    if (state.isEmpty) return;

    final db = ref.read(localDbProvider);
    final inventoryController = ref.read(inventoryControllerProvider);

    for (var cartItem in state) {
      await db.transaksiDao.prosesPenjualan(
        barangId: cartItem.barang.id,
        qtyInput: cartItem.qty,
        hargaJualPerSatuanInput: cartItem.hargaJual,
        tipe: 'eceran_kasir',
      );

      await inventoryController.refreshCacheAfterCheckout(cartItem.barang.id);
    }

    clearCart();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
