class KalkulatorService {
  // 1. Hitung kebutuhan panjang/gulungan (contoh: kabel, selang, kawat)
  static double hitungPanjangKabel({required double totalMeterDibutuhkan, required double panjangPerRoll}) {
    if (panjangPerRoll <= 0) return 0;
    return totalMeterDibutuhkan / panjangPerRoll;
  }

  // 2. Konversi Satuan Grosir ke Eceran (Dus/Kotak ke Pcs)
  static int konversiKePcs({required int jumlahDus, required int isiPerDus}) {
    return jumlahDus * isiPerDus;
  }

  // 3. Estimasi Kebutuhan Baut / Paku berdasarkan panjang bidang (meter lari)
  static int hitungKebutuhanPakuBaut({required double panjangBidangMeter, required double jarakAntarTitikCm}) {
    if (jarakAntarTitikCm <= 0) return 0;
    // Ubah meter ke cm lalu bagi jarak, ditambah 1 untuk titik awal
    final cm = panjangBidangMeter * 100;
    return ((cm / jarakAntarTitikCm) + 1).ceil();
  }
}
