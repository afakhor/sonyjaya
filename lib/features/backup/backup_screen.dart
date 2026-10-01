import 'package:flutter/material.dart';
import 'services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  String _statusText = 'Belum ada proses backup yang dijalankan.';

  Future<void> _jalankanBackup() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Sedang mencadangkan database...';
    });

    try {
      final path = await BackupService.exportDatabase();
      setState(() {
        _statusText = 'Berhasil dicadangkan ke:\n$path';
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Cadangan & Pemulihan Data'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.blueAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Catatan Penting:\nKarena aplikasi berjalan secara lokal di perangkat Anda, lakukan pencadangan data secara berkala (misal seminggu sekali) agar data transaksi, stok, dan bon piutang aman.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isLoading ? null : _jalankanBackup,
              icon: const Icon(Icons.backup),
              label: const Text('CADANGKAN DATABASE SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Text('Status Proses:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Text(_statusText, style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }
}
