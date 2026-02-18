// ── main.dart ─────────────────────────────────────────────────
// Entry point of the app

import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';

void main() async {
  // Needed before using any async code in main
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Load saved preferences
    final dark = await StorageService.loadDarkMode();
    final isFirstTime = await StorageService.isFirstTime();

    setState(() {
      _isDark = dark;
      _showOnboarding = isFirstTime;
      _loading = false;
    });
  }

  void _onSplashComplete() {
    setState(() => _showSplash = false);
  }

  void _onOnboardingComplete() async {
    await StorageService.setOnboardingSeen();
    setState(() => _showOnboarding = false);
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickIt',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Light theme ────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // ── Dark theme ─────────────────────────────────────────
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E293B),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // ── Route logic ────────────────────────────────────────
      home: _loading
          ? const Scaffold(
              backgroundColor: Color(0xFF6366F1),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : _showSplash
              ? SplashPage(onComplete: _onSplashComplete)
              : _showOnboarding
                  ? OnboardingPage(onContinue: _onOnboardingComplete)
                  : HomePage(
                      isDark: _isDark,
                      onToggleTheme: _toggleTheme,
                    ),
    );
  }
}
