import 'package:flutter/material.dart';
class PelangganRatingService {
  static String warnaPiutang(DateTime jatuhTempo, String status){
    if(status=='LUNAS') return 'HIJAU';
    final d = DateTime.now().difference(jatuhTempo).inDays;
    if(d<=0) return 'HITAM';
    if(d<=30) return 'KUNING';
    if(d<=60) return 'MERAH';
    return 'MERAH_TUA';
  }
  static Color colorWarna(String w){
    switch(w){ case 'HIJAU': return const Color(0xFF16A34A); case 'HITAM': return const Color(0xFF0F172A); case 'KUNING': return const Color(0xFFEAB308); case 'MERAH': return const Color(0xFFDC2626); case 'MERAH_TUA': return const Color(0xFF7F1D1D); default: return Colors.grey; }
  }
}