import 'package:flutter/material.dart';
import 'services/kalkulator_service.dart';

class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});

  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  // Controller Tab 1: Kabel / Selang
  final _meterKabelController = TextEditingController();
  final _panjangRollController = TextEditingController(text: '50'); // Default 50 meter per roll
  String _hasilKabel = '';

  // Controller Tab 2: Konversi Dus/Box ke Pcs
  final _jumlahDusController = TextEditingController();
  final _isiPerDusController = TextEditingController(text: '12'); // Default 12 pcs per dus
  String _hasilPcs = '';

  // Controller Tab 3: Simulasi Diskon Bertingkat & Margin HPP
  final _hargaAsliController = TextEditingController();
  final _diskon1Controller = TextEditingController(); // cth: 10 (%)
  final _diskon2Controller = TextEditingController(); // cth: 5 (%)
  final _hppModalController = TextEditingController();
  String _hasilSimulasiDiskon = '';
  Map<String, dynamic>? _analisisMarginResult;

  void _hitungKabel() {
    final meter = double.tryParse(_meterKabelController.text) ?? 0;
    final roll = double.tryParse(_panjangRollController.text) ?? 1;
    final totalRoll = KalkulatorService.hitungPanjangKabel(totalMeterDibutuhkan: meter, panjangPerRoll: roll);
    setState(() {
      _hasilKabel = 'Dibutuhkan sekitar ${totalRoll.toStringAsFixed(1)} Roll (${totalRoll.ceil()} Roll utuh)';
    });
  }

  void _hitungPcs() {
    int dus = int.tryParse(_jumlahDusController.text) ?? 0;
    int isi = int.tryParse(_isiPerDusController.text) ?? 1;
    int total = KalkulatorService.konversiKePcs(jumlahDus: dus, isiPerDus: isi);
    setState(() {
      _hasilPcs = 'Total keseluruhan: $total Pcs / Satuan Dasar';
    });
  }

  void _hitungSimulasiDiskonDanMargin() {
    final hargaAsli = double.tryParse(_hargaAsliController.text) ?? 0;
    final d1 = double.tryParse(_diskon1Controller.text) ?? 0;
    final d2 = double.tryParse(_diskon2Controller.text) ?? 0;
    final hpp = double.tryParse(_hppModalController.text) ?? 0;

    List<double> listDiskon = [];
    if (d1 > 0) listDiskon.add(d1);
    if (d2 > 0) listDiskon.add(d2);

    // Hitung Compound Discount
    final hargaSetelahDiskon = KalkulatorService.hitungDiskonBertingkat(hargaAsli, listDiskon);
    final totalDiskonNominal = hargaAsli - hargaSetelahDiskon;

    // Analisis Margin HPP
    final margin = KalkulatorService.analisisMargin(hargaJualAkhir: hargaSetelahDiskon, hppBarang: hpp);

    setState(() {
      _hasilSimulasiDiskon = 'Harga Jual Bersih: Rp ${hargaSetelahDiskon.toStringAsFixed(0)} (Potongan: Rp ${totalDiskonNominal.toStringAsFixed(0)})';
      _analisisMarginResult = margin;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E293B);

    return DefaultTabController(
      length: 3, // Diubah menjadi 3 tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kalkulator Cepat Toko Perkakas'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.cable), text: 'Kabel / Selang'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Konversi Dus ke Pcs'),
              Tab(icon: Icon(Icons.percent), text: 'Simulasi Diskon & HPP'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Kalkulator Kabel / Selang
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Hitung Kebutuhan Roll Kabel / Selang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _meterKabelController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Meter yang Dibutuhkan Pembeli', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _panjangRollController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Panjang Per Roll (Meter)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    onPressed: _hitungKabel,
                    child: const Text('Hitung Kebutuhan Roll'),
                  ),
                  const SizedBox(height: 24),
                  if (_hasilKabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(_hasilKabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                ],
              ),
            ),

            // TAB 2: Kalkulator Konversi Dus
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Konversi Satuan Dus / Kotak ke Pcs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _jumlahDusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Dus / Kotak', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _isiPerDusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Isi per Dus (Pcs)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    onPressed: _hitungPcs,
                    child: const Text('Konversi ke Pcs'),
                  ),
                  const SizedBox(height: 24),
                  if (_hasilPcs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(_hasilPcs, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                ],
              ),
            ),

            // TAB 3: Simulasi Diskon Bertingkat & Margin HPP (Baru)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Simulasi Diskon Bertingkat & Cek Margin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _hargaAsliController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga Normal Barang (Rp)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _diskon1Controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Diskon 1 (%)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _diskon2Controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Diskon 2 (%)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _hppModalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Modal HPP Satuan (Rp)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    onPressed: _hitungSimulasiDiskonDanMargin,
                    child: const Text('Simulasi & Analisis Margin'),
                  ),
                  const SizedBox(height: 24),
                  if (_hasilSimulasiDiskon.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_hasilSimulasiDiskon, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const Divider(height: 16),
                          if (_analisisMarginResult != null) ...[
                            Text('Margin Rupiah: Rp ${_analisisMarginResult!['marginRupiah'].toStringAsFixed(0)}'),
                            Text('Margin Persen: ${_analisisMarginResult!['marginPersen'].toStringAsFixed(1)}%'),
                            const SizedBox(height: 8),
                            Text(
                              _analisisMarginResult!['peringatan'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _analisisMarginResult!['isRugi'] ? Colors.red : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
