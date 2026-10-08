import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/cache/isar_service.dart';
import 'core/background/auto_worker.dart';
import 'features/kasir/kasir_screen.dart';
import 'features/inventory/import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  try { await AutoWorker.init(); } catch (_) {}
  runApp(const ProviderScope(child: SonyJayaApp()));
}

// Notifier tetap tapi jangan dipakai untuk rebuild UI berat
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
        scaffoldBackgroundColor: Colors.white, // FIX ABU: jangan F8FAFC, pakai putih
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0),
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

  // FIX: jangan const, kasih PageStorageKey biar tidak blank abu saat IndexedStack switch
  late final List<Widget> _screens = [
    const KasirScreen(key: PageStorageKey('kasir')),
    const InventoryScreen(key: PageStorageKey('stok')),
    const TransaksiScreen(key: PageStorageKey('transaksi')),
    const AutoPoScreen(key: PageStorageKey('autopo')),
    const ExtraFeaturesMenu(key: PageStorageKey('menu')),
  ];

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // FIX ABU PINDAH: timer 5 menit jangan invalidate di tengah build, pakai post-frame + cek mounted
    _autoTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // hanya invalidate inventory, jangan increment tick yang bikin ExtraMenu rebuild abu
        ref.invalidate(inventoryStreamProvider);
      });
    });
  }

  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(inventoryStreamProvider);
    }
  }

  @override void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    // FIX: jangan watch autoRefreshProvider di sini, itu bikin IndexedStack rebuild jadi abu
    return Scaffold(
      backgroundColor: Colors.white, // FIX ABU: putih solid
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: const Color(0xFFE8F0FE),
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
    // FIX: jangan watch autoRefreshProvider, itu penyebab abu pindah ke Supplier
    // final refreshTick = ref.watch(autoRefreshProvider); -> HAPUS

    final menuItems = [
      {'title': 'Input + Beli HPP', 'icon': Icons.shopping_cart, 'color': const Color(0xFF10B981), 'screen': const BarangMasukScreen()},
      {'title': 'Master Supplier', 'icon': Icons.local_shipping, 'color': const Color(0xFF3B82F6), 'screen': const SupplierScreen()},
      {'title': 'Katalog Perkakas', 'icon': Icons.build, 'color': const Color(0xFFF59E0B), 'screen': const PerkakasScreen()},
      {'title': 'Buku Hutang', 'icon': Icons.money_off, 'color': const Color(0xFFEF4444), 'screen': const HutangScreen()},
      {'title': 'Buku Piutang', 'icon': Icons.receipt, 'color': const Color(0xFF8B5CF6), 'screen': const PiutangScreen()},
      {'title': 'Kalkulator Toko', 'icon': Icons.calculate, 'color': const Color(0xFF06B6D4), 'screen': const KalkulatorScreen()},
      {'title': 'Log & Audit', 'icon': Icons.history, 'color': const Color(0xFF64748B), 'screen': const LogScreen()},
      {'title': 'Backup BSKRO', 'icon': Icons.backup, 'color': const Color(0xFF0F172A), 'screen': const BackupScreen()},
    ];

    return Scaffold(
      backgroundColor: Colors.white, // FIX ABU
      appBar: AppBar(
        title: const Text('Fitur Tambahan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF9FAFB), // cantik: abu sangat muda, bukan abu tua foto kamu
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, i) {
            final item = menuItems[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                  ),
                  const Spacer(),
                  Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  const Text('Tap untuk buka', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  try { await AutoWorker.init(); } catch (_) {}
  runApp(const ProviderScope(child: SonyJayaApp()));
}

// Notifier tetap tapi jangan dipakai untuk rebuild UI berat
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
        scaffoldBackgroundColor: Colors.white, // FIX ABU: jangan F8FAFC, pakai putih
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0),
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

  // FIX: jangan const, kasih PageStorageKey biar tidak blank abu saat IndexedStack switch
  late final List<Widget> _screens = [
    const KasirScreen(key: PageStorageKey('kasir')),
    const InventoryScreen(key: PageStorageKey('stok')),
    const TransaksiScreen(key: PageStorageKey('transaksi')),
    const AutoPoScreen(key: PageStorageKey('autopo')),
    const ExtraFeaturesMenu(key: PageStorageKey('menu')),
  ];

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // FIX ABU PINDAH: timer 5 menit jangan invalidate di tengah build, pakai post-frame + cek mounted
    _autoTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // hanya invalidate inventory, jangan increment tick yang bikin ExtraMenu rebuild abu
        ref.invalidate(inventoryStreamProvider);
      });
    });
  }

  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(inventoryStreamProvider);
    }
  }

  @override void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    // FIX: jangan watch autoRefreshProvider di sini, itu bikin IndexedStack rebuild jadi abu
    return Scaffold(
      backgroundColor: Colors.white, // FIX ABU: putih solid
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: const Color(0xFFE8F0FE),
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
    // FIX: jangan watch autoRefreshProvider, itu penyebab abu pindah ke Supplier
    // final refreshTick = ref.watch(autoRefreshProvider); -> HAPUS

    final menuItems = [
      {'title': 'Input + Beli HPP', 'icon': Icons.shopping_cart, 'color': const Color(0xFF10B981), 'screen': const BarangMasukScreen()},
      {'title': 'Master Supplier', 'icon': Icons.local_shipping, 'color': const Color(0xFF3B82F6), 'screen': const SupplierScreen()},
      {'title': 'Katalog Perkakas', 'icon': Icons.build, 'color': const Color(0xFFF59E0B), 'screen': const PerkakasScreen()},
      {'title': 'Buku Hutang', 'icon': Icons.money_off, 'color': const Color(0xFFEF4444), 'screen': const HutangScreen()},
      {'title': 'Buku Piutang', 'icon': Icons.receipt, 'color': const Color(0xFF8B5CF6), 'screen': const PiutangScreen()},
      {'title': 'Kalkulator Toko', 'icon': Icons.calculate, 'color': const Color(0xFF06B6D4), 'screen': const KalkulatorScreen()},
      {'title': 'Log & Audit', 'icon': Icons.history, 'color': const Color(0xFF64748B), 'screen': const LogScreen()},
      {'title': 'Backup BSKRO', 'icon': Icons.backup, 'color': const Color(0xFF0F172A), 'screen': const BackupScreen()},
    ];

    return Scaffold(
      backgroundColor: Colors.white, // FIX ABU
      appBar: AppBar(
        title: const Text('Fitur Tambahan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF9FAFB), // cantik: abu sangat muda, bukan abu tua foto kamu
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, i) {
            final item = menuItems[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                  ),
                  const Spacer(),
                  Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  const Text('Tap untuk buka', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
