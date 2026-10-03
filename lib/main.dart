import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/local_database.dart';
import 'core/cache/isar_service.dart';
import 'core/background/auto_worker.dart';

import 'features/kasir/kasir_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/inventory/barang_masuk_screen.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'features/po/auto_po_screen.dart';
import 'features/transaksi/transaksi_screen.dart';
import 'features/hutang/hutang_screen.dart';
import 'features/piutang/piutang_screen.dart';
import 'features/kalkulator/kalkulator_screen.dart';
import 'features/backup/backup_screen.dart';
import 'features/log/log_screen.dart';
import 'features/perkakas/perkakas_screen.dart';
import 'features/supplier/supplier_screen.dart';
import 'features/supplier/supplier_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await IsarService.init();
    await AutoWorker.init();
  } catch (e) {
    debugPrint('Error init service: $e');
  }
  runApp(const ProviderScope(child: SonyJayaApp()));
}

// === GLOBAL AUTO UPDATE NOTIFIER ===
final autoRefreshProvider = StateProvider<int>((ref) => 0);

class SonyJayaApp extends StatelessWidget {
  const SonyJayaApp({super.key});
  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3B82F6);
    return MaterialApp(
      title: 'Sony Jaya iPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light, background: const Color(0xFFF8FAFC), surface: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)), side: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFDBEAFE),
          elevation: 2,
          labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});
  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _autoTimer;

  final List<Widget> _screens = const [
    KasirScreen(),
    InventoryScreen(),
    TransaksiScreen(),
    AutoPoScreen(),
    ExtraFeaturesMenu(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // AUTO UPDATE TIAP 15 DETIK + SAAT APP RESUME
    _autoTimer = Timer.periodic(const Duration(seconds: 15), (_) => _refreshAll());
  }

  void _refreshAll() {
    // invalidate semua stream biar ke-fetch ulang dari Drift
    ref.invalidate(inventoryStreamProvider);
    ref.invalidate(supplierListProvider);
    ref.read(autoRefreshProvider.notifier).state++;
    // debug
    debugPrint('🔄 Auto update data ${DateTime.now()}');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listen global refresh trigger
    ref.watch(autoRefreshProvider);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Kasir'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Stok'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Auto PO'),
          NavigationDestination(icon: Icon(Icons.widgets_outlined), selectedIcon: Icon(Icons.widgets), label: 'Menu Lain'),
        ],
      ),
    );
  }
}

class ExtraFeaturesMenu extends ConsumerWidget {
  const ExtraFeaturesMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // auto refresh trigger
    final refreshTick = ref.watch(autoRefreshProvider);

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Input + Beli HPP',
        'subtitle': 'Auto suggest & update HPP',
        'icon': Icons.add_shopping_cart_rounded,
        'color': const Color(0xFF10B981),
        'screen': const BarangMasukScreen(),
      },
      {
        'title': 'Master Supplier',
        'subtitle': 'Hutang & riwayat belanja',
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFF3B82F6),
        'screen': const SupplierScreen(),
      },
      {
        'title': 'Katalog Perkakas',
        'subtitle': 'Filter merek & stok',
        'icon': Icons.handyman_rounded,
        'color': const Color(0xFFF59E0B),
        'screen': const PerkakasScreen(),
      },
      {
        'title': 'Buku Hutang',
        'subtitle': 'Vendor belum lunas',
        'icon': Icons.money_off_rounded,
        'color': const Color(0xFFEF4444),
        'screen': const HutangScreen(),
      },
      {
        'title': 'Buku Piutang',
        'subtitle': 'Customer bon',
        'icon': Icons.request_quote_rounded,
        'color': const Color(0xFF8B5CF6),
        'screen': const PiutangScreen(),
      },
      {
        'title': 'Kalkulator Toko',
        'subtitle': 'Hitung laba cepat',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFF06B6D4),
        'screen': const KalkulatorScreen(),
      },
      {
        'title': 'Log & Audit',
        'subtitle': 'Kartu stok FIFO',
        'icon': Icons.history_rounded,
        'color': const Color(0xFF64748B),
        'screen': const LogScreen(),
      },
      {
        'title': 'Backup.BSKRO',
        'subtitle': 'Cadang & upload Drive',
        'icon': Icons.cloud_upload_rounded,
        'color': const Color(0xFF0F172A),
        'screen': const BackupScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Fitur Tambahan'),
        backgroundColor: Colors.white,
        actions: [
          // indikator auto update hidup
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Auto $refreshTick', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget));
              // SETELAH BALIK DARI SCREEN, AUTO REFRESH
              ref.read(autoRefreshProvider.notifier).state++;
              ref.invalidate(inventoryStreamProvider);
              ref.invalidate(supplierListProvider);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(item['icon'] as IconData, size: 26, color: item['color'] as Color),
                  ),
                  const Spacer(),
                  Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(item['subtitle'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}