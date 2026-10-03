import 'package:drift/drift.dart';
import '../local_database.dart';
part 'supplier_dao.g.dart';

@DriftAccessor(tables: [Supplier, Pembelian, PurchaseOrders, Barang])
class SupplierDao extends DatabaseAccessor<LocalDatabase> with _$SupplierDaoMixin {
  SupplierDao(super.db);
  Stream<List<SupplierData>> watchAll() => (select(supplier)..orderBy([(s) => OrderingTerm.asc(s.nama)])).watch();
  Future<SupplierData?> getByNama(String nama) => (select(supplier)..where((s) => s.nama.equals(nama))).getSingleOrNull();
  Future<int> upsertSupplier(String nama, {String? kontak, String? alamat}) async {
    final exist = await getByNama(nama);
    if (exist!= null) return exist.id;
    return into(supplier).insert(SupplierCompanion.insert(nama: nama, kontak: Value(kontak), alamat: Value(alamat)));
  }
  Future<Map<String, dynamic>> getInfoSupplier(String namaSupplier) async {
    final belis = await (select(pembelian)..where((p) => p.supplier.equals(namaSupplier))).get();
    final totalBelanja = belis.fold<double>(0, (sum, b) => sum + (b.qtyPcs * b.hargaBeliPerPcs));
    final barangIds = belis.map((e) => e.barangId).toSet().toList();
    List<BarangData> barangs = [];
    if (barangIds.isNotEmpty) {
      barangs = await (select(barang)..where((b) => b.id.isIn(barangIds))).get();
    }
    final pos = await (select(purchaseOrders)..where((p) => p.namaRelasi.equals(namaSupplier) & p.tipePo.equals('VENDOR') & p.statusBayar.equals('BELUM_LUNAS'))).get();
    final totalHutang = pos.fold<double>(0, (sum, p) => sum + p.totalKeseluruhan);
    return {'totalBelanja': totalBelanja, 'totalHutang': totalHutang, 'jumlahTransaksi': belis.length, 'daftarBarang': barangs, 'daftarPo': pos};
  }
}