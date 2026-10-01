import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/local_database.dart';
import 'core/cache/isar_service.dart';
import 'core/background/auto_worker.dart';

// Provider global untuk mengakses database Drift
final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Isar Cache untuk pencarian kilat
  await IsarService.init();
  
  // 2. Inisialisasi Background Worker (Workmanager)
  initAutoWorker();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sony Jaya iPOS 5',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SONY JAYA - iPOS 5 Auto-Control'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context,
            title: 'Modul Kasir & Penjualan',
            subtitle: 'Dilengkapi P001 Anti-Minus & Margin Guard',
            icon: Icons.point_of_sale,
            onTap: () {
              // Navigasi ke halaman kasir
            },
          ),
          _buildMenuCard(
            context,
            title: 'Purchase Order (PO Customer & Vendor)',
            subtitle: 'Sinkronisasi otomatis ke stok & HPP',
            icon: Icons.receipt_long,
            onTap: () {
              // Navigasi ke halaman PO
            },
          ),
          _buildMenuCard(
            context,
            title: 'Stock Opname Gudang',
            subtitle: 'Audit fisik dan penyesuaian selisih stok',
            icon: Icons.inventory_2,
            onTap: () {
              // Navigasi ke halaman Stock Opname
            },
          ),
          _buildMenuCard(
            context,
            title: 'Kalkulator Material Bangunan',
            subtitle: 'Hitung kebutuhan keramik, semen, dll otomatis',
            icon: Icons.calculate,
            onTap: () {
              // Panggil MaterialCalculatorService di sini
            },
          ),
          _buildMenuCard(
            context,
            title: 'Pengaturan Master Satuan',
            subtitle: 'Tambah / Hapus satuan (Pcs, Sak, Dus, dll)',
            icon: Icons.category,
            onTap: () {
              // Navigasi ke pengaturan satuan
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
