import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_database.dart';
import '../inventory/providers/inventory_provider.dart';
import 'package:drift/drift.dart' as drift;

class SupplierDetailScreen extends ConsumerStatefulWidget {
  final SupplierData supplier;
  const SupplierDetailScreen({super.key, required this.supplier});
  @override ConsumerState<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  late SupplierData sup;

  @override
  void initState() {
    super.initState();
    sup = widget.supplier;
  }

  Future<void> _editKontakAlamat() async {
    final kontakCtrl = TextEditingController(text: sup.kontak ?? '');
    final alamatCtrl = TextEditingController(text: sup.alamat ?? '');
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Edit Keterangan ${sup.nama}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: kontakCtrl, decoration: const InputDecoration(labelText: 'Kontak (WA/Telp)', prefixIcon: Icon(Icons.phone)),),
          const SizedBox(height: 12),
          TextField(controller: alamatCtrl, decoration: const InputDecoration(labelText: 'Alamat Lengkap', prefixIcon: Icon(Icons.location_on)), maxLines: 3),
        ]),
        actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Batal')), ElevatedButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Simpan'))],
      ),
    );
    if(res==true){
      final db = ref.read(localDbProvider);
      await db.supplierDao.updateKontakAlamat(sup.id, kontakCtrl.text, alamatCtrl.text);
      final updated = await (db.select(db.supplier)..where((s)=>s.id.equals(sup.id))).getSingle();
      setState(()=> sup = updated);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keterangan supplier disimpan')));
    }
  }

  Future<void> _bayarLunas(PurchaseOrder po) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c)=> AlertDialog(
        title: const Text('Bayar Lunas Hutang?'),
        content: Text('PO ${po.noPo}\nTotal Rp ${po.totalKeseluruhan.toStringAsFixed(0)}\nSupplier ${po.namaRelasi}\n\nTanggal Bayar: ${DateTime.now().toString().substring(0,16)}\n\nAkan dicatat di Log.'),
        actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Batal')), ElevatedButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Ya, Bayar Lunas'))],
      ),
    );
    if(confirm==true){
      final db = ref.read(localDbProvider);
      await db.supplierDao.bayarHutangPo(po.id);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PO ${po.noPo} LUNAS pada ${DateTime.now()}')));
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(localDbProvider);
    return Scaffold(
      appBar: AppBar(title: Text(sup.nama), actions: [IconButton(icon: const Icon(Icons.edit_rounded), onPressed: _editKontakAlamat, tooltip: 'Edit Kontak/Alamat')]),
      body: FutureBuilder<Map<String,dynamic>>(
        future: db.supplierDao.getInfoSupplier(sup.nama),
        builder: (c,snap){
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          final totalBelanja = data['totalBelanja'] as double;
          final totalHutang = data['totalHutang'] as double;
          final jumlahTx = data['jumlahTransaksi'] as int;
          final daftarBarang = data['daftarBarang'] as List<BarangData>;
          final daftarPo = data['daftarPo'] as List<PurchaseOrder>;

          return ListView(padding: const EdgeInsets.all(16), children: [
            // CARD MERAH YANG DILINGKARI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.store_rounded, color: Color(0xFF2563EB))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sup.nama, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Kontak: ${sup.kontak?.isEmpty==true?'-':sup.kontak??'-'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    Text('Alamat: ${sup.alamat?.isEmpty==true?'-':sup.alamat??'-'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ])),
                  IconButton(onPressed: _editKontakAlamat, icon: const Icon(Icons.edit, size: 18), tooltip: 'Input keterangan supplier disini'),
                ]),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Belanja'), Text('Rp ${totalBelanja.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Hutang Belum Lunas'), Text('Rp ${totalHutang.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: totalHutang>0? Colors.red : Colors.grey))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Jumlah Transaksi Beli'), Text('$jumlahTx kali')]),
              ]),
            ),

            const SizedBox(height: 20),
            const Text('Barang yang pernah dibeli dari supplier ini:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...daftarBarang.map((b)=> Card(child: ListTile(title: Text(b.nama, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('SKU: ${b.sku??'-'} | Stok: ${b.stok} | HPP: Rp ${b.hppAverage.toStringAsFixed(0)}')))),

            const SizedBox(height: 20),
            // CARD BIRU YANG DILINGKARI
            const Text('PO Hutang Belum Lunas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if(daftarPo.isEmpty)
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))), child: const Text('Tidak ada hutang.', style: TextStyle(color: Color(0xFF15803D))))
            else
              ...daftarPo.map((po)=> Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(po.noPo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Tanggal PO: ${po.tanggalPo.toString().substring(0,16)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Total: Rp ${po.totalKeseluruhan.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('Status Bayar: ${po.statusBayar} ${po.statusBayar=='BELUM_LUNAS'? '(Sisa Rp ${po.totalKeseluruhan.toStringAsFixed(0)})' : '(Lunas pada ${DateTime.now().toString().substring(0,10)})'}', style: TextStyle(fontSize: 12, color: po.statusBayar=='BELUM_LUNAS'? Colors.red : Colors.green)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: (){}, child: const Text('Detail PO'))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton.icon(onPressed: ()=>_bayarLunas(po), icon: const Icon(Icons.payments_rounded, size: 16), label: const Text('Bayar Lunas'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white))),
                  ]),
                ]),
              )),

            const SizedBox(height: 20),
            const Text('Cara biar masuk hutang:', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const Text('1. Saat Input Barang Masuk, pilih Status Bayar = BELUM LUNAS\n2. Otomatis masuk ke sini + Hutang + Log', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]);
        },
      ),
    );
  }
}