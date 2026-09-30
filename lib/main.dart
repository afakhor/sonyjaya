import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/cache/isar_service.dart';
import 'core/background/auto_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init(); // WAJIB
  initAutoWorker();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(home: Scaffold(body: Center(child: Text('SONY JAYA Backend Matang'))));
}