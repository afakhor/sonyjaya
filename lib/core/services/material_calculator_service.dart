class MaterialCalculatorService {
  static int hitungDusKeramik({required double panjangM, required double lebarM}) {
    final luasRuangan = panjangM * lebarM;
    const luasPerDus = 0.96; 
    final kebutuhanMurni = luasRuangan / luasPerDus;
    final denganCadangan = kebutuhanMurni * 1.05; 
    return denganCadangan.ceil();
  }

  static int hitungSakSemenMortar(double luasDindingM2) {
    final sak = luasDindingM2 / 10;
    return sak.ceil();
  }
}
