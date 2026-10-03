import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/database/local_database.dart';

class BackupService {
  // Cari file DB asli - nama aslimu sony_jaya_hpp_v5
  static Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dirList = dbFolder.listSync();
    for (var f in dirList) {
      if (f is File && f.path.contains('sony_jaya')) {
        return f;
      }
    }
    // fallback untuk kompatibilitas kode lamamu
    final legacy1 = File(p.join(dbFolder.path, 'sony_jaya_hpp_v5.sqlite'));
    if (await legacy1.exists()) return legacy1;
    final legacy2 = File(p.join(dbFolder.path, 'sony_jaya_pos.sqlite'));
    return legacy2;
  }

  // EXPORT .BSKRO - ini yang kamu minta
  static Future<String> exportBskro() async {
    final dbFile = await getDatabaseFile();
    if (!await dbFile.exists()) {
      throw Exception('File database tidak ditemukan di ${dbFile.path}');
    }

    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = 'SONYJAYA_$timestamp.bskro';
    final backupPath = p.join(directory.path, fileName);

    final savedFile = await dbFile.copy(backupPath);
    return savedFile.path;
  }

  // Wrapper biar kode lamamu tetap jalan
  static Future<String?> exportDatabase() async {
    return await exportBskro();
  }

  // RESTORE DARI .BSKRO
  static Future<void> restoreBskro(String bskroPath) async {
    final bskroFile = File(bskroPath);
    if (!await bskroFile.exists()) throw Exception('File .bskro tidak ada');
    if (!bskroPath.toLowerCase().endsWith('.bskro')) throw Exception('Bukan file .bskro');

    // tutup koneksi dulu
    try {
      final db = LocalDatabase();
      await db.close();
    } catch (_) {}

    final dbFile = await getDatabaseFile();
    // overwrite
    await bskroFile.copy(dbFile.path);
  }

  // UPLOAD .BSKRO KE SERVER / GOOGLE DRIVE / WA
  static Future<String> uploadBskro(String bskroPath, {String? uploadUrl}) async {
    final file = File(bskroPath);
    if (!await file.exists()) throw Exception('File tidak ada');

    // Jika uploadUrl tidak diisi, akan pakai share system (WA, Drive, dll)
    // Jika diisi, upload via http multipart
    if (uploadUrl == null || uploadUrl.isEmpty) {
      throw Exception('Gunakan Share, atau isi uploadUrl');
    }

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', bskroPath));
    request.fields['filename'] = p.basename(bskroPath);
    request.fields['app'] = 'sony_jaya';
    
    final response = await request.send();
    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception('Upload gagal status ${response.statusCode}');
    }
  }

  static bool isBskro(String path) => path.toLowerCase().endsWith('.bskro');
}