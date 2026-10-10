// lib/features/hutang/hutang_screen.dart - FINAL FIX KALENDER + MULTI NOTA PER TANGGAL + TANPA DUMMY
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'providers/hutang_provider.dart';

class HutangScreen extends ConsumerStatefulWidget {
  const HutangScreen({super.key});
  @override ConsumerState<HutangScreen> createState() => _HutangScreenState();
}

class _HutangScreenState extends ConsumerState<HutangScreen> {
  DateTime viewMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime selectedDate = DateTime.now();
  final DateTime today = DateTime.now();

  String fmtRp(double n) => "Rp ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  bool isSameDay(DateTime a, DateTime b) => a.year==b.year && a.month==b.month && a.day==b.day;

  // Status warna: hitam <30, kuning = jatuh tempo hari ini, merah 60+ lewat, hijau kosong
  Color statusColor(HutangSupplierData h){
    final diff = today.difference(h.tanggalNota).inDays;
    if(h.statusBayar=='LUNAS') return const Color(0xFF22C55E);
    if(diff>=60) return const Color(0xFFEF4444); // merah
    final tempoDiff = h.jatuhTempo.difference(today).inDays;
    if(tempoDiff==0) return const Color(0xFFFACC15); // kuning jatuh tempo hari ini
    return const Color(0xFF0F172A); // hitam <30
  }
  String statusLabel(HutangSupplierData h){
    final diff = today.difference(h.tanggalNota).inDays;
    if(h.statusBayar=='LUNAS') return 'LUNAS';
    if(diff>=60) return '60+ LEWAT';
    if(h.jatuhTempo.difference(today).inDays==0) return 'JATUH TEMPO';
    return '<30 AMAN';
  }

  Map<String, List<HutangSupplierData>> groupByDate(List<HutangSupplierData> list){
    final map = <String, List<HutangSupplierData>>{};
    for(var h in list){
      final key = "${h.tanggalNota.year}-${h.tanggalNota.month.toString().padLeft(2,'0')}-${h.tanggalNota.day.toString().padLeft(2,'0')}";
      map.putIfAbsent(key, ()=>[]).add(h);
    }
    return map;
  }

  @override
  Widget build(BuildContext context){
    final hutangAsync = ref.watch(hutangListProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EB),
      body: hutangAsync.when(
        data: (hutangs){
          final inMonth = hutangs.where((h)=> h.tanggalNota.year==viewMonth.year && h.tanggalNota.month==viewMonth.month).toList();
          final grouped = groupByDate(hutangs);
          final totalBulan = inMonth.fold<double>(0,(s,h)=> s+h.totalTagihan);

          // calendar days
          final firstDay = DateTime(viewMonth.year, viewMonth.month, 1);
          final lastDay = DateTime(viewMonth.year, viewMonth.month+1, 0);
          final startWeekday = firstDay.weekday % 7; // 0=Min
          final days = <DateTime?>[];
          for(int i=0;i<startWeekday;i++) days.add(null);
          for(int d=1; d<=lastDay.day; d++) days.add(DateTime(viewMonth.year, viewMonth.month, d));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16,16,16,8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Kalender card
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withOpacity(0.08))),
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    // Nav hijau
                    Row(children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(24)),
                        child: Row(children: [
                          InkWell(onTap: ()=> setState(()=> viewMonth = DateTime(viewMonth.year, viewMonth.month-1,1)), child: const Padding(padding: EdgeInsets.symmetric(horizontal:12,vertical:8), child: Text("<", style: TextStyle(fontWeight: FontWeight.bold)))),
                          Container(width:1,height:16,color: Colors.black12),
                          InkWell(onTap: ()=> setState(()=> viewMonth = DateTime(viewMonth.year, viewMonth.month+1,1)), child: const Padding(padding: EdgeInsets.symmetric(horizontal:12,vertical:8), child: Text(">", style: TextStyle(fontWeight: FontWeight.bold)))),
                        ]),
                      ),
                      const SizedBox(width:10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("${_monthName(viewMonth.month)} ${viewMonth.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16)),
                        Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year} hari ini", style: const TextStyle(fontSize:10,color: Colors.black54)),
                      ]),
                      const Spacer(),
                      // Kuning: hari ini hanya kembali ke hari ini kalender bulan ini
                      InkWell(
                        onTap: ()=> setState((){
                          viewMonth = DateTime(today.year, today.month,1);
                          selectedDate = today;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal:14,vertical:7),
                          decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(24)),
                          child: Text("Hari ini ${today.day}/${today.month}/${today.year}", style: const TextStyle(fontSize:11,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                    const SizedBox(height:12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ["Min","Sen","Sel","Rab","Kam","Jum","Sab"].map((e)=> Text(e, style: const TextStyle(fontSize:11,color: Colors.black38,fontWeight: FontWeight.bold))).toList()),
                    const SizedBox(height:8),
                    GridView.builder(
                      shrinkWrap:true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7, mainAxisSpacing:4,crossAxisSpacing:4, childAspectRatio:0.9),
                      itemCount: days.length,
                      itemBuilder: (_,i){
                        final date = days[i];
                        if(date==null) return const SizedBox();
                        final key = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
                        final list = grouped[key] ?? [];
                        final isSel = isSameDay(date, selectedDate);
                        final isToday = isSameDay(date, today);
                        return InkWell(
                          onTap: (){
                            setState(()=> selectedDate = date);
                            if(list.isNotEmpty){
                              _showDetailMulti(context, date, list);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSel? Colors.black : const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(14),
                              border: isToday && !isSel? Border.all(color: Colors.black26): null,
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text("${date.day}", style: TextStyle(fontSize:14,fontWeight: FontWeight.bold, color: isSel? Colors.white: Colors.black)),
                              const SizedBox(height:2),
                              if(list.isEmpty)
                                Container(width:5,height:5,decoration: const BoxDecoration(color: Color(0xFF86EFAC), shape: BoxShape.circle))
                              else
                                Wrap(spacing:2, children: [
                                  ...list.take(3).map((h)=> Container(width:6,height:6,decoration: BoxDecoration(color: isSel? Colors.white : statusColor(h), shape: BoxShape.circle))),
                                  if(list.length>1) Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: Text("${list.length}", style: const TextStyle(fontSize:7,color: Colors.white))),
                                ]),
                            ]),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height:8),
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _LegendDot(color: Color(0xFF0F172A), label:"<30 hari"),
                      SizedBox(width:8),
                      _LegendDot(color: Color(0xFFFACC15), label:"jatuh tempo"),
                      SizedBox(width:8),
                      _LegendDot(color: Color(0xFFEF4444), label:"60+ hari"),
                      SizedBox(width:8),
                      _LegendDot(color: Color(0xFF86EFAC), label:"kosong"),
                    ]),
                  ]),
                ),
                const SizedBox(height:16),
                // NOTA BULAN INI - biru ngikut hijau
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("NOTA ${_monthName(viewMonth.month).toUpperCase()} ${viewMonth.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16)),
                  Container(padding: const EdgeInsets.symmetric(horizontal:10,vertical:4), decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(24)), child: Text("${_monthName(viewMonth.month).toUpperCase()} ${viewMonth.year}", style: const TextStyle(color: Colors.white,fontSize:10))),
                ]),
              ]))),
              SliverList.builder(
                itemCount: inMonth.length,
                itemBuilder: (_,idx){
                  final h = inMonth[idx];
                  final isMulti = grouped["${h.tanggalNota.year}-${h.tanggalNota.month.toString().padLeft(2,'0')}-${h.tanggalNota.day.toString().padLeft(2,'0')}"]!.length>1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal:16,vertical:4),
                    child: InkWell(
                      onTap: ()=> _showDetailMulti(context, h.tanggalNota, grouped["${h.tanggalNota.year}-${h.tanggalNota.month.toString().padLeft(2,'0')}-${h.tanggalNota.day.toString().padLeft(2,'0')}"]!),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
                        child: Row(children: [
                          Container(width:44,height:44,decoration: BoxDecoration(color: statusColor(h), borderRadius: BorderRadius.circular(12)), child: Center(child: Text("${h.tanggalNota.day}", style: TextStyle(color: statusColor(h)==const Color(0xFFFACC15)? Colors.black: Colors.white, fontWeight: FontWeight.bold)))),
                          const SizedBox(width:10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [Flexible(child: Text(h.supplierNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:13), overflow: TextOverflow.ellipsis)), if(isMulti) Container(margin: const EdgeInsets.only(left:4), padding: const EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: Text("${grouped["${h.tanggalNota.year}-${h.tanggalNota.month.toString().padLeft(2,'0')}-${h.tanggalNota.day.toString().padLeft(2,'0')}"]!.length} nota", style: const TextStyle(color: Colors.white,fontSize:9)))]),
                            Text("${h.noNota} • ${h.tanggalNota.day} ${_monthName(h.tanggalNota.month)} ${h.tanggalNota.year}", style: const TextStyle(fontSize:11,color: Colors.black54)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(fmtRp(h.totalTagihan), style: const TextStyle(fontWeight: FontWeight.bold, fontSize:12)),
                            Text(statusLabel(h), style: TextStyle(fontSize:10, color: statusColor(h)==const Color(0xFF0F172A)? Colors.black54: statusColor(h), fontWeight: FontWeight.bold)),
                          ]),
                        ]),
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height:80)),
            ],
          );
        },
        loading: ()=> const Center(child: CircularProgressIndicator()),
        error: (e,_ )=> Center(child: Text("Error $e")),
      ),
    );
  }

  void _showDetailMulti(BuildContext ctx, DateTime date, List<HutangSupplierData> list){
    showModalBottomSheet(context: ctx, isScrollControlled:true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_){
      return StatefulBuilder(builder: (ctx,setStateSheet){
        int idx = 0;
        final h = list[idx];
        return DraggableScrollableSheet(initialChildSize:0.85, maxChildSize:0.95, minChildSize:0.6, expand:false, builder: (ctx,scroll){
          return ListView(controller: scroll, padding: const EdgeInsets.all(16), children: [
            if(list.length>1) Column(children: [
              Text("${list.length} NOTA DI ${date.day} ${_monthName(date.month).toUpperCase()} ${date.year}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height:8),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(list.length, (i)=> Padding(padding: const EdgeInsets.only(right:6), child: ChoiceChip(label: Text(list[i].noNota, style: const TextStyle(fontSize:11)), selected: idx==i, onSelected: (_)=> setStateSheet(()=> idx=i)))))),
              const SizedBox(height:12),
            ]),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(16)), child: Column(children: [
              _field("Nama Supplier", h.supplierNama),
              _field("Nomor Nota", h.noNota),
              _field("Tanggal Nota", "${h.tanggalNota.day}/${h.tanggalNota.month}/${h.tanggalNota.year}"),
              _field("Tanggal Jatuh Tempo", "${h.jatuhTempo.day}/${h.jatuhTempo.month}/${h.jatuhTempo.year}", color: statusColor(h)),
              _field("Penerima", h.supplierNama),
              _field("Alamat Supplier", h.supplierNama),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Tagihan", style: TextStyle(fontWeight: FontWeight.bold)), Text(fmtRp(h.totalTagihan), style: const TextStyle(fontWeight: FontWeight.bold))]),
            ])),
            const SizedBox(height:12),
            // Kuning & Orange
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: ()=> _showCicilan(ctx, h), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFACC15), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), child: const Text("Lihat Cicilan"))),
              const SizedBox(width:8),
              Expanded(child: ElevatedButton(onPressed: ()=> _showHarga(ctx, h), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEDD5), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), child: const Text("Lihat Harga"))),
            ]),
          ]);
        });
      });
    });
  }

  Widget _field(String label, String val, {Color? color}) => Padding(padding: const EdgeInsets.symmetric(vertical:4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize:11,color: Colors.black54, fontWeight: FontWeight.bold)), const SizedBox(width:12), Flexible(child: Text(val, style: TextStyle(fontSize:12, fontWeight: FontWeight.w500, color: color), textAlign: TextAlign.right))]));

  void _showCicilan(BuildContext ctx, HutangSupplierData h){
    final db = ref.read(localDbProvider);
    showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFFFEF9C3), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_){
      final ctrl = TextEditingController();
      DateTime tgl = DateTime.now();
      return StatefulBuilder(builder: (ctx,setS){
        return Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Pembayaran Cicil - ${h.noNota}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:12),
          TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText:"Nominal", border: OutlineInputBorder(), isDense:true)),
          const SizedBox(height:8),
          Row(children: [
            Expanded(child: Text("Tgl: ${tgl.day}/${tgl.month}/${tgl.year}")),
            TextButton(onPressed: () async { final d = await showDatePicker(context: ctx, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDate: tgl); if(d!=null) setS(()=> tgl=d); }, child: const Text("Pilih Tanggal")),
          ]),
          const SizedBox(height:8),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: ()=> ctrl.text = h.sisaHutang.toStringAsFixed(0), child: const Text("Lunas Sisa"))),
            const SizedBox(width:8),
            Expanded(child: ElevatedButton(onPressed: () async {
              final bayar = double.tryParse(ctrl.text)??0;
              if(bayar<=0) return;
              final sisa = h.sisaHutang - bayar;
              await (db.update(db.hutangSupplier)..where((t)=> t.id.equals(h.id))).write(HutangSupplierCompanion(totalDibayar: Value(h.totalDibayar+bayar), sisaHutang: Value(sisa<=0?0:sisa), statusBayar: Value(sisa<=0?'LUNAS':'BELUM_LUNAS')));
              await db.into(db.pembayaranHutang).insert(PembayaranHutangCompanion.insert(hutangId: h.id, jumlahBayar: bayar, tanggalBayar: Value(tgl)));
              if(ctx.mounted) Navigator.pop(ctx);
            }, child: const Text("Simpan Cicilan"))),
          ]),
        ]));
      });
    });
  }

  void _showHarga(BuildContext ctx, HutangSupplierData h){
    showModalBottomSheet(context: ctx, backgroundColor: Colors.white, builder: (_)=> Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Rincian Harga - ${h.noNota}", style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:8),
      Text("Total: ${fmtRp(h.totalTagihan)}"),
      const SizedBox(height:8),
      const Text("Harga Ecer / Agen / Manual ada di Nota Masuk", style: TextStyle(fontSize:11,color: Colors.black54)),
    ])));
  }

  String _monthName(int m){
    const names = ["","Januari","Februari","Maret","April","Mei","Juni","Juli","Agustus","September","Oktober","November","Desember"];
    return names[m];
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override Widget build(BuildContext context)=> Row(children: [Container(width:8,height:8,decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width:4), Text(label, style: const TextStyle(fontSize:10))]);
}
