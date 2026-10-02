import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/local_database.dart';
import 'core/cache/isar_service.dart';
import 'core/background/auto_worker.dart';

import 'features/kasir/kasir_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/po/auto_po_screen.dart';
import 'features/transaksi/transaksi_screen.dart'; 
import 'features/hutang/hutang_screen.dart';         
import 'features/piutang/piutang_screen.dart';     
import 'features/kalkulator/kalkulator_screen.dart'; 
import 'features/backup/backup_screen.dart';       
import 'features/log/log_screen.dart';             
import 'features/perkakas/perkakas_screen.dart';   

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  // Layar utama termasuk Menu Tambahan di index terakhir
  final List<Widget> _screens = const [
    KasirScreen(),
    InventoryScreen(),
    TransaksiScreen(),
    AutoPoScreen(),
    ExtraFeaturesMenu(), // Screen baru untuk memaksimalkan akses folder features
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
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Stok'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Auto PO'),
          NavigationDestination(icon: Icon(Icons.widgets), label: 'Menu Lain'),
        ],
      ),
    );
  }
}

// Widget khusus untuk mengakomodasi layar fitur sekunder
class ExtraFeaturesMenu extends StatelessWidget {
  const ExtraFeaturesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Katalog Perkakas', 'icon': Icons.handyman, 'screen': const PerkakasScreen()},
      {'title': 'Buku Hutang', 'icon': Icons.money_off, 'screen': const HutangScreen()},
      {'title': 'Buku Piutang', 'icon': Icons.request_quote, 'screen': const PiutangScreen()},
      {'title': 'Kalkulator Toko', 'icon': Icons.calculate, 'screen': const KalkulatorScreen()},
      {'title': 'Log & Audit', 'icon': Icons.history, 'screen': const LogScreen()},
      {'title': 'Backup Data', 'icon': Icons.save, 'screen': const BackupScreen()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitur Tambahan'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'])),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 48, color: Colors.orange.shade300),
                  const SizedBox(height: 12),
                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
