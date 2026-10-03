import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  String _statusText = 'Belum ada proses backup.';
  String? _lastBskroPath;

  Future<void> _backupBskro() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Membuat file .bskro...';
    });
    try {
      final path = await BackupService.exportBskro();
      setState(() {
        _lastBskroPath = path;
        _statusText = 'BERHASIL .BSKRO\n$path\n\nFile ini bisa di-share ke WA / Google Drive.';
      });
    } catch (e) {
      setState(() => _statusText = 'Error backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBskro() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bskro'],
    );
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      _isLoading = true;
      _statusText = 'Restore dari:\n$path...';
    });
    try {
      await BackupService.restoreBskro(path);
      setState(() => _statusText = 'RESTORE BERHASIL!\nRestart aplikasi untuk melihat data kembali.');
    } catch (e) {
      setState(() => _statusText = 'Gagal restore: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareUpload() async {
    if (_lastBskroPath == null) {
      // kalau belum backup, buat dulu
      await _backupBskro();
      if (_lastBskroPath == null) return;
    }
    try {
      final file = XFile(_lastBskroPath!);
      await Share.shareXFiles([file], text: 'Backup Sony Jaya .bskro - ${DateTime.now()}');
      setState(() => _statusText = 'File .bskro di-share:\n$_lastBskroPath');
    } catch (e) {
      setState(() => _statusText = 'Gagal share: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E293B);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Cadangan .BSKRO'),
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
                  'Format .BSKRO (Backup Sony Jaya Kro) adalah file database asli yang diganti ekstensi jadi .bskro agar tidak tertukar. Bisa di-upload ke Google Drive, WA, atau Email.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _isLoading ? null : _backupBskro,
              icon: const Icon(Icons.backup),
              label: const Text('1. CADANGKAN JADI .BSKRO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _isLoading ? null : _shareUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('2. UPLOAD / SHARE .BSKRO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _isLoading ? null : _restoreBskro,
              icon: const Icon(Icons.restore),
              label: const Text('3. RESTORE DARI .BSKRO'),
            ),
            const SizedBox(height: 24),
            const Text('Status Proses:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(child: Text(_statusText, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
              ),
            ),
            if (_lastBskroPath != null) ...[
              const SizedBox(height: 12),
              Text('File terakhir: ${File(_lastBskroPath!).path.split('/').last}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }
}