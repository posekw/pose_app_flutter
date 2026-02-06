import 'package:flutter/material.dart';
import 'widgets/main_nav.dart';

void main() async {
  // CRITICAL: Initialize Flutter bindings before any plugin usage
  // This fixes path_provider_foundation crash (null pointer at 0x0000000000000000)
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Media',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212), // Global dark background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF1744), // Red accent
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}