import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptService {
  // Widget struk bersih untuk pembeli - TANPA HPP/MARGIN/ECER/AGEN
  static Widget buildStrukWidget({required List<Map<String, dynamic>> items, required double grandTotal, required String tanggal, required String nota}) {
    return Container(
      width: 380,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Center(child: Text('SONY JAYA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
        const Center(child: Text('Jl. Raya Toko - 0812-xxxx', style: TextStyle(fontSize: 10, color: Colors.grey))),
        const Divider(),
        Text('No: $nota | Tgl: $tanggal', style: const TextStyle(fontSize: 10)),
        const Divider(),
        ...items.map((it)=> Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(it['nama'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${it['qty']} x Rp ${it['harga']}', style: const TextStyle(fontSize: 11)),
            Text('Rp ${it['subtotal']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        ]))),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text('Rp ${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        const Center(child: Text('Terima Kasih Telah Berbelanja!', style: TextStyle(fontSize: 11))),
        const Center(child: Text('Barang yang sudah dibeli tidak dapat dikembalikan', style: TextStyle(fontSize: 9, color: Colors.grey))),
      ]),
    );
  }

  static Future<File> captureWidgetToJpg(GlobalKey key) async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/struk_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(pngBytes);
    return file;
  }
}