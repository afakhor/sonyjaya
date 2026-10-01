class ReceiptService {
  // Struk Bersih untuk Pelanggan (Tanpa rincian diskon bertingkat atau HPP)
  static String generateStrukPelanggan({
    required String namaToko,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
  }) {
    String struk = '$namaToko\n--------------------------------\n';
    for (var item in items) {
      struk += '${item['nama']} x${item['qty']} ${item['satuan']}\n';
      struk += '   @Rp ${item['harga']} = Rp ${item['subtotal']}\n';
    }
    struk += '--------------------------------\n';
    struk += 'TOTAL BERSIH: Rp $grandTotal\n';
    struk += 'Terima Kasih Telah Berbelanja!\n';
    return struk;
  }

  // Laporan Latar Belakang untuk Pemilik (Via WhatsApp / Catatan Audit)
  static String generateLaporanPemilik({
    required int notaId,
    required String namaPelanggan,
    required double totalKotor,
    required double diskonBertingkatDiterapkan,
    required double totalBersih,
    required double totalHppModal,
  }) {
    final estimasiUntung = totalBersih - totalHppModal;
    return '''[AUDIT PEMILIK - NOTA #$notaId]
Pelanggan: $namaPelanggan
--------------------------------
Harga Kotor: Rp $totalKotor
Diskon Bertingkat: Rp $diskonBertingkatDiterapkan
Omset Bersih: Rp $totalBersih
Estimasi Modal (HPP): Rp $totalHppModal
ESTIMASI LABA BERSIH: Rp $estimasiUntung
status: Terverifikasi Margin Guardian
''';
  }
}
