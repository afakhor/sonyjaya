import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../inventory/providers/inventory_provider.dart';

// State untuk kata kunci pencarian & kategori perkakas yang dipilih
class PerkakasFilterState {
  final String searchQuery;
  final String selectedCategory;

  PerkakasFilterState({
    this.searchQuery = '',
    this.selectedCategory = 'SEMUA',
  });
}

// Notifier berbasis Riverpod 2.x (Notifier<T>)
class PerkakasFilterNotifier extends Notifier<PerkakasFilterState> {
  @override
  PerkakasFilterState build() {
    return PerkakasFilterState();
  }

  void setSearchQuery(String query) {
    state = PerkakasFilterState(
      searchQuery: query,
      selectedCategory: state.selectedCategory,
    );
  }

  void setCategory(String category) {
    state = PerkakasFilterState(
      searchQuery: state.searchQuery,
      selectedCategory: category,
    );
  }
}

final perkakasFilterProvider =
    NotifierProvider<PerkakasFilterNotifier, PerkakasFilterState>(
  PerkakasFilterNotifier.new,
);

// Provider utama yang memfilter daftar barang khusus perkakas
final filteredPerkakasProvider =
    Provider.autoDispose<AsyncValue<List<BarangData>>>((ref) {
  final inventoryAsync = ref.watch(inventoryStreamProvider);
  final filter = ref.watch(perkakasFilterProvider);

  return inventoryAsync.whenData((barangs) {
    return barangs.where((b) {
      final nama = b.nama.toLowerCase();
      final sku = (b.sku ?? '').toLowerCase();

      final matchesSearch =
          nama.contains(filter.searchQuery.toLowerCase()) ||
          sku.contains(filter.searchQuery.toLowerCase());

      if (filter.selectedCategory == 'SEMUA') return matchesSearch;
      return matchesSearch &&
          nama.contains(filter.selectedCategory.toLowerCase());
    }).toList();
  });
});
