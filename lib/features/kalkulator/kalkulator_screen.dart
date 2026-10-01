import 'package:flutter/material.dart';
import 'services/kalkulator_service.dart';

class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});

  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  final _tabController = DefaultTabController(
    length: 2,
    child: Container(),
  );

  // Controller Tab 1: Kabel / Selang
  final _meterKabelController = TextEditingController();
  final _panjangRollController = TextEditingController(text: '50'); // Default 50 meter per roll
  String _hasilKabel = '';

  // Controller Tab 2: Konversi Dus/Box ke Pcs
  final _jumlahDusController = TextEditingController();
  final _isiPerDusController = TextEditingController(text: '12'); // Default 12 pcs per dus
  String _hasilPcs = '';

  @functionalHitungKabel() {
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E293B);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kalkulator Cepat Toko Perkakas'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.cable), text: 'Kabel / Selang'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Konversi Dus ke Pcs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Kalkulator Kabel / Selang
            Padding(
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
            Padding(
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
          ],
        ),
      ),
    );
  }
}

// Helper annotation placeholder if needed for custom syntax tricks
class functionalHitungKabel {
  const functionalHitungKabel();
}
