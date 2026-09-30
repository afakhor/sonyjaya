import 'package:isar_community/isar.dart';
part 'fast_stock_cache.g.dart';

@collection
class FastStockCache {
  Id id = Isar.autoIncrement; // id = barangId
  int? barangId;
  String? nama;
  int stok = 0;
  double tor = 0; // dihitung Workmanager tiap jam
  bool isFastMoving = false;
  @Index()
  DateTime lastUpdated = DateTime.now();
}