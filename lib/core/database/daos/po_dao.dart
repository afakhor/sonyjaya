import 'package:drift/drift.dart';
import '../local_database.dart';
import 'transaksi_dao.dart';

part 'po_dao.g.dart';

@DriftAccessor(tables: [PurchaseOrders, PurchaseOrderItems, Barang, KartuStok, Pembelian, Penjualan])
class PoDao extends DatabaseAccessor<LocalDatabase> with _$PoDaoMixin {
  late final TransaksiDao transaksiDao;

  PoDao(LocalDatabase db) : super(db) {
    transaksiDao = TransaksiDao(db);
  }

  Future<int> buatPurchaseOrder({
    required String noPo,
    required String tipePo, 
    required String namaRelasi,
    required String kontakRelasi,
    required String alamatRelasi,
    DateTime? estimasiKirim,
    required String statusBayar,
    required List<Map<String, dynamic>> items, 
  }) async {
    return await transaction(() async {
      double grandTotal = 0;

      for (var item in items) {
        final double sub = (item['qty'] as int) * (item['hargaSatuan'] as double);
        grandTotal += sub;
      }

      final poId = await into(db.purchaseOrders).insert(
        PurchaseOrdersCompanion.insert(
          noPo: noPo,
          tipePo: tipePo,
          namaRelasi: namaRelasi,
          kontakRelasi: kontakRelasi,
          alamatRelasi: alamatRelasi,
          estimasiKirim: Value(estimasiKirim),
          statusBayar: Value(statusBayar),
          totalKeseluruhan: Value(grandTotal),
          statusPo: const Value('PENDING'),
        ),
      );

      for (var item in items) {
        final int barangId = item['barangId'];
        final barang = await (select(db.barang)..where((b) => b.id.equals(barangId))).getSingle();

        final int qty = item['qty'];
        final double hargaSatuan = item['hargaSatuan'];
        final double subtotal = qty * hargaSatuan;

        await into(db.purchaseOrderItems).insert(
          PurchaseOrderItemsCompanion.insert(
            poId: poId,
            barangId: barangId,
            qty: qty,
            satuan: item['satuan'] ?? 'Pcs',
            hargaSatuan: hargaSatuan,
            subtotal: subtotal,
            hppSaatTransaksi: barang.hppAverage,
          ),
        );
      }

      return poId;
    });
  }

  Future<void> selesaikanDanSinkronkanPo(int poId) async {
    await transaction(() async {
      final po = await (select(db.purchaseOrders)..where((p) => p.id.equals(poId))).getSingle();
      if (po.statusPo == 'SELESAI') return; 

      final items = await (select(db.purchaseOrderItems)..where((i) => i.poId.equals(poId))).get();

      for (var item in items) {
        if (po.tipePo == 'VENDOR') {
          // DISESUAIKAN: Menggunakan parameter 'qtyInput' & 'hargaBeliPerSatuanInput' sesuai transaksi_dao.dart
          await transaksiDao.prosesPembelian(
            barangId: item.barangId,
            qtyInput: item.qty,
            hargaBeliPerSatuanInput: item.hargaSatuan,
            supplier: po.namaRelasi,
            isSatuanBesar: false, // Ubah ke true jika satuan PO menggunakan satuan besar
          );
        } else if (po.tipePo == 'CUSTOMER') {
          // DISESUAIKAN: Menggunakan parameter 'qtyInput' & 'hargaJualPerSatuanInput' sesuai transaksi_dao.dart
          await transaksiDao.prosesPenjualan(
            barangId: item.barangId,
            qtyInput: item.qty,
            hargaJualPerSatuanInput: item.hargaSatuan,
            tipe: 'po_customer',
            isSatuanBesar: false, // Ubah ke true jika satuan PO menggunakan satuan besar
          );
        }
      }

      await (update(db.purchaseOrders)..where((p) => p.id.equals(poId))).write(
        const PurchaseOrdersCompanion(statusPo: Value('SELESAI'))
      );
    });
  }
}
