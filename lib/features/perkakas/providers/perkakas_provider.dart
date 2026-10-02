import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// State untuk kata kunci pencarian & kategori perkakas yang dipilih
class PerkakasFilterState {
  final String searchQuery;
  final String selectedCategory;

  PerkakasFilterState({this.searchQuery = '', this.selectedCategory = 'SEMUA'});
}

class PerkakasFilterNotifier extends StateNotifier<PerkakasFilterState> {
  PerkakasFilterNotifier() : super(PerkakasFilterState());

  void setSearchQuery(String query) {
    state = PerkakasFilterState(searchQuery: query, selectedCategory: state.selectedCategory);
  }

  void setCategory(String category) {
    state = PerkakasFilterState(searchQuery: state.searchQuery, selectedCategory: category);
  }
}

final perkakasFilterProvider = StateNotifierProvider<PerkakasFilterNotifier, PerkakasFilterState>((ref) {
  return PerkakasFilterNotifier();
});

// Provider utama yang memfilter daftar barang khusus perkakas
final filteredPerkakasProvider = Provider.autoDispose<AsyncValue<List<BarangData>>>((ref) {
  final inventoryAsync = ref.watch(inventoryStreamProvider);
  final filter = ref.watch(perkakasFilterProvider);

  return inventoryAsync.whenData((barangs) {
    return barangs.where((b) {
      // Filter asumsi kategori atau nama barang mengandung kata kunci perkakas
      // (Bisa disesuaikan jika di database Anda ada kolom kategori khusus)
      final nama = b.nama.toLowerCase();
      final sku = (b.sku ?? '').toLowerCase();
      
      final matchesSearch = nama.contains(filter.searchQuery.toLowerCase()) || 
                            sku.contains(filter.searchQuery.toLowerCase());
      
      // Contoh filter kategori berdasarkan nama/tag jika belum ada kolom kategori di DB
      if (filter.selectedCategory == 'SEMUA') return matchesSearch;
      return matchesSearch && nama.contains(filter.selectedCategory.toLowerCase());
    }).toList();
  });
});
