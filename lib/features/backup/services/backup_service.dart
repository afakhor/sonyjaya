import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  // Mendapatkan path file database Drift lokal
  static Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sony_jaya_pos.sqlite')); // Sesuaikan nama file DB Anda
    return file;
  }

  // 1. Ekspor / Cadangkan Database ke Folder Eksternal / Download
  static Future<String?> exportDatabase() async {
    try {
      final dbFile = await getDatabaseFile();
      if (!await dbFile.exists()) {
        throw Exception('File database tidak ditemukan!');
      }

      // Ambil direktori penyimpanan eksternal / download pengguna
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = p.join(directory.path, 'backup_sony_jaya_$timestamp.sqlite');

      // Salin file database
      final savedFile = await dbFile.copy(backupPath);
      return savedFile.path;
    } catch (e) {
      throw Exception('Gagal melakukan backup: $e');
    }
  }
}
