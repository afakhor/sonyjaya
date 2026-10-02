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

  // Inisialisasi Service Global
  try {
    await IsarService.init();
    await AutoWorker.init();
  } catch (e) {
    debugPrint('Error saat inisialisasi service: $e');
  }

  runApp(
    const ProviderScope(
      child: SonyJayaApp(),
    ),
  );
}

class SonyJayaApp extends StatelessWidget {
  const SonyJayaApp({super.key});

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
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Daftar screen utama - Tidak memanggil method/provider internal features
  final List<Widget> _screens = const [
    KasirScreen(),
    InventoryScreen(),
    TransaksiScreen(),
    AutoPoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
}