// ── main.dart ─────────────────────────────────────────────────
// Entry point of the app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/home_widget_service.dart';
import 'providers/theme_provider.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService.init();
  await HomeWidgetService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isFirstTime = await StorageService.isFirstTime();
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
        theme: themeProvider.lightTheme,
        darkTheme: themeProvider.darkTheme,
        home: _loading
            ? Scaffold(
                backgroundColor: themeProvider.seedColor,
                body: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : _showSplash
                ? SplashPage(onComplete: _onSplashComplete)
                : _showOnboarding
                    ? OnboardingPage(onContinue: _onOnboardingComplete)
                    : const HomePage(),
      );
    });
  }
}
