import 'package:flutter/material.dart';
class PelangganRatingService {
  static String warnaPiutang(DateTime jatuhTempo, String statusBayar){
    if(statusBayar=='LUNAS') return 'HIJAU';
    final lewat = DateTime.now().difference(jatuhTempo).inDays;
    if(lewat>=60) return 'MERAH_TUA';
    if(lewat>=31) return 'MERAH';
    if(lewat>=15) return 'KUNING';
    return 'HITAM';
  }
  static Color colorWarna(String warna){
    switch(warna){
      case 'HIJAU': return Colors.green;
      case 'KUNING': return Colors.amber.shade700;
      case 'MERAH': return Colors.red;
      case 'MERAH_TUA': return Colors.red.shade900;
      default: return Colors.black;
    }
  }
}
