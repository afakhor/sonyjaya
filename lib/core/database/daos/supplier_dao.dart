import 'package:drift/drift.dart';
import '../local_database.dart';
part 'supplier_dao.g.dart';

@DriftAccessor(tables: [Supplier,PurchaseOrders,Barang,KartuStok])
class SupplierDao extends DatabaseAccessor<LocalDatabase> with _$SupplierDaoMixin {
  SupplierDao(super.db);
  
  Stream<List<SupplierData>> watchAll() => (select(supplier)..orderBy([(s)=> OrderingTerm.asc(s.nama)])).watch();
  
  Future<void> upsertSupplier(String nama) async {
    await into(supplier).insertOnConflictUpdate(SupplierCompanion.insert(nama: nama));
  }
  
  Future<void> updateKontakAlamat(int id, String kontak, String alamat, {String? ket, int? top}) async {
    await (update(supplier)..where((s)=>s.id.equals(id))).write(SupplierCompanion(
      kontak: Value(kontak.isEmpty? null : kontak),
      alamat: Value(alamat.isEmpty? null : alamat),
      keterangan: ket!=null? Value(ket) : const Value.absent(),
      topDefault: top!=null? Value(top) : const Value.absent(),
    ));
  }

  Future<Map<String,dynamic>> getInfoSupplier(String namaSupplier) async {
    final allPo = await (select(purchaseOrders)..where((p)=>p.namaRelasi.equals(namaSupplier))).get();
    final totalBelanja = allPo.fold<double>(0,(sum,p)=> sum + p.totalKeseluruhan);
    final totalHutang = allPo.where((p)=>p.statusBayar!='LUNAS').fold<double>(0,(sum,p)=> sum + p.totalKeseluruhan);
    final barangs = await (select(barang)..where((b)=>b.supplier.equals(namaSupplier))).get();
    return {'totalBelanja':totalBelanja,'totalHutang':totalHutang,'jumlahTransaksi':allPo.length,'daftarBarang':barangs,'daftarPo':allPo.where((p)=>p.statusBayar!='LUNAS').toList()};
  }

  Future<void> bayarHutangPo(int poId) async {
    await (update(purchaseOrders)..where((p)=>p.id.equals(poId))).write(const PurchaseOrdersCompanion(statusBayar: Value('LUNAS')));
    final po = await (select(purchaseOrders)..where((p)=>p.id.equals(poId))).getSingle();
    await into(kartuStok).insert(KartuStokCompanion.insert(barangId: 1, tipe: 'BAYAR_HUTANG_SUPPLIER', qty: 0, stokAkhir: 0, hargaBeliSaatItu: Value(po.totalKeseluruhan), refId: Value('LUNAS PO ${po.noPo} ${DateTime.now()}')));
  }
}