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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SonyJayaApp()));
  Future.microtask(() async {
    try {
      await IsarService.init();
      await AutoWorker.init();
    } catch (_) {}
  });
}

class AutoRefreshNotifier extends Notifier<int> {
  @override int build() => 0;
  void increment() => state++;
}
final autoRefreshProvider = NotifierProvider<AutoRefreshNotifier, int>(AutoRefreshNotifier.new);

class SonyJayaApp extends StatelessWidget {
  const SonyJayaApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sony Jaya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});
  @override ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _autoTimer;
  final List<Widget> _screens = const [
    KasirScreen(), InventoryScreen(), TransaksiScreen(), AutoPoScreen(), ExtraFeaturesMenu(),
  ];
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(seconds: 2), () => _refreshAll());
    _autoTimer = Timer.periodic(const Duration(minutes: 5), (_) => _refreshAll());
  }
  void _refreshAll() {
    ref.invalidate(inventoryStreamProvider);
    ref.read(autoRefreshProvider.notifier).increment();
  }
  @override void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    super.dispose();
  }
  @override Widget build(BuildContext context) {
    ref.watch(autoRefreshProvider);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: 'Kasir'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Stok'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Auto PO'),
          NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Menu Lain'),
        ],
      ),
    );
  }
}

class ExtraFeaturesMenu extends ConsumerWidget {
  const ExtraFeaturesMenu({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final refreshTick = ref.watch(autoRefreshProvider);
    final menuItems = [
      {'title': 'Input + Beli HPP', 'icon': Icons.shopping_cart, 'color': const Color(0xFF10B981), 'screen': const BarangMasukScreen()},
      {'title': 'Master Supplier', 'icon': Icons.local_shipping, 'color': const Color(0xFF3B82F6), 'screen': const SupplierScreen()},
      {'title': 'Katalog Perkakas', 'icon': Icons.build, 'color': const Color(0xFFF59E0B), 'screen': const PerkakasScreen()},
      {'title': 'Buku Hutang', 'icon': Icons.money_off, 'color': const Color(0xFFEF4444), 'screen': const HutangScreen()},
      {'title': 'Buku Piutang', 'icon': Icons.receipt, 'color': const Color(0xFF8B5CF6), 'screen': const PiutangScreen()},
      {'title': 'Kalkulator Toko', 'icon': Icons.calculate, 'color': const Color(0xFF06B6D4), 'screen': const KalkulatorScreen()},
      {'title': 'Log & Audit', 'icon': Icons.history, 'color': const Color(0xFF64748B), 'screen': const LogScreen()},
      {'title': 'Backup.BSKRO', 'icon': Icons.backup, 'color': const Color(0xFF0F172A), 'screen': const BackupScreen()},
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Fitur Tambahan - Auto $refreshTick')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15),
        itemCount: menuItems.length,
        itemBuilder: (context, i) {
          final item = menuItems[i];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget)),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(item['icon'] as IconData, color: item['color'] as Color),
                const Spacer(),
                Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        },
      ),
    );
  }
}