import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers.dart';
import 'data/sample_data.dart';
import 'data/local/app_database.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await seedSampleData(db);
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF1abc9c);
    const darkPrimaryColor = Color(0xFF16a085);

    return MaterialApp(
      title: 'Personal Finance - Daily Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: primaryColor,
          tertiary: Color(0xFF7c3aed),
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: darkPrimaryColor,
          secondary: primaryColor,
          tertiary: Color(0xFF7c3aed),
          surface: Color.fromARGB(255, 120, 123, 121),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
