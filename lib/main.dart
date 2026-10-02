import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/local_database.dart';
import 'core/cache/isar_service.dart';
import 'core/background/auto_worker.dart';

// Import seluruh fitur dari folder lib/features/
import 'features/kasir/kasir_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/po/auto_po_screen.dart';
import 'features/transaksi/transaksi_screen.dart'; // Sesuaikan jika nama file berbeda
import 'features/hutang/hutang_screen.dart';         // Sesuaikan jika nama file berbeda
import 'features/piutang/piutang_screen.dart';     // Sesuaikan jika nama file berbeda
import 'features/kalkulator/kalkulator_screen.dart'; // Sesuaikan jika nama file berbeda
import 'features/backup/backup_screen.dart';       // Sesuaikan jika nama file berbeda
import 'features/log/log_screen.dart';             // Sesuaikan jika nama file berbeda
import 'features/perkakas/perkakas_screen.dart';   // Sesuaikan jika nama file berbeda

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Database Lokal & Cache
  await IsarService.init();
  
  // Memperbaiki pemanggilan fungsi inisialisasi Worker yang benar
  await AutoWorker.init();

  runApp(
    const ProviderScope(
      child: SonyJayaApp(),
    ),
  );
}

class SonyJayaApp extends StatelessWidget {
  const SonyJayaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sony Jaya iPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Daftar Screen Utama untuk Bottom Navigation Bar
  final List<Widget> _mainScreens = [
    const KasirScreen(),
    const InventoryScreen(),
    const TransaksiScreen(),
    const AutoPoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => _showFullMenuModal(context),
            tooltip: 'Menu Fitur Lengkap',
          )
        ],
      ),
      body: _mainScreens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Auto PO',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Sony Jaya - Kasir';
      case 1: return 'Manajemen Inventory';
      case 2: return 'Riwayat Transaksi';
      case 3: return 'Auto Purchase Order';
      default: return 'Sony Jaya iPOS';
    }
  }

  // Modal / BottomSheet untuk mengakses seluruh fitur lengkap sesuai direktori gambar
  void _showFullMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 10,
          children: [
            const Text(
              'Semua Modul & Fitur', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.redAccent),
              title: const Text('Hutang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HutangScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.greenAccent),
              title: const Text('Piutang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PiutangScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.amber),
              title: const Text('Kalkulator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KalkulatorScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.blueAccent),
              title: const Text('Backup & Restore'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orangeAccent),
              title: const Text('Log Sistem'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LogScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.purpleAccent),
              title: const Text('Perkakas (Tools)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PerkakasScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
