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

      // 1. Langsung simpan dengan status SELESAI (Auto)
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
          statusPo: const Value('SELESAI'),
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

        // 2. OTOMATIS SINKRONKAN STOK SEKETIKA SAAT PO DIBUAT
        if (tipePo == 'VENDOR') {
          await transaksiDao.prosesPembelian(
            barangId: barangId,
            qtyInput: qty,
            hargaBeliPerSatuanInput: hargaSatuan,
            supplier: namaRelasi,
            isSatuanBesar: false,
          );
        } else if (tipePo == 'CUSTOMER') {
          await transaksiDao.prosesPenjualan(
            barangId: barangId,
            qtyInput: qty,
            hargaJualPerSatuanInput: hargaSatuan,
            tipe: 'po_customer',
            isSatuanBesar: false,
          );
        }
      }

      return poId;
    });
  }
}
