import 'package:isar_community/isar.dart';
part 'fast_stock_cache.g.dart';

@collection
class FastStockCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  int barangId = 0;

  String nama = '';
  String sku = '';
  int stok = 0;
  int safetyStock = 5;
  double hppAverage = 0;
  double tor = 0; // Turnover Rate
  bool isFastMoving = false;
  bool perluReorder = false;
  DateTime lastUpdated = DateTime.now();
}