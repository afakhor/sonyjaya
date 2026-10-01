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
    final cm = panjangBidangMeter * 100;
    return ((cm / jarakAntarTitikCm) + 1).ceil();
  }

  // 4. Perhitungan Diskon Bertingkat Tersembunyi (Compound Discount, cth: 10% + 5%)
  static double hitungDiskonBertingkat(double hargaAsli, List<double> persentaseDiskon) {
    double hargaAkhir = hargaAsli;
    for (var diskon in persentaseDiskon) {
      hargaAkhir = hargaAkhir - (hargaAkhir * (diskon / 100));
    }
    return hargaAkhir;
  }

  // 5. Analisis Saran Margin HPP (Mencegah Rugi Selisih Harga)
  static Map<String, dynamic> analisisMargin({
    required double hargaJualAkhir,
    required double hppBarang,
  }) {
    final marginRupiah = hargaJualAkhir - hppBarang;
    final marginPersen = hppBarang == 0 ? 0.0 : (marginRupiah / hppBarang) * 100;
    final isRugi = hargaJualAkhir < hppBarang;

    return {
      'marginRupiah': marginRupiah,
      'marginPersen': marginPersen,
      'isRugi': isRugi,
      'peringatan': isRugi ? 'BAHAYA: Harga jual di bawah HPP (Rugi!)' : 'Aman (Margin Positif)'
    };
  }
}
