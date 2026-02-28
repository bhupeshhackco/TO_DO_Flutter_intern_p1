// ── providers/theme_provider.dart ─────────────────────────────
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

enum AppColorScheme {
  defaultScheme,
  ember,
  forest,
  sunset,
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode     = ThemeMode.light;
  AppColorScheme _colorScheme = AppColorScheme.defaultScheme;
  bool _isPureBlack = false;
  bool _compact     = false;
  bool _noAnim      = false;
  bool _streak      = true;

  ThemeMode      get themeMode   => _themeMode;
  AppColorScheme get colorScheme => _colorScheme;
  bool get isPureBlack => _isPureBlack;
  bool get compact     => _compact;
  bool get noAnim      => _noAnim;
  bool get streak      => _streak;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _themeMode   = await StorageService.loadThemeMode();
    _colorScheme = await StorageService.loadColorScheme();
    _isPureBlack = await StorageService.loadPureBlack();
    _compact     = await StorageService.loadBool('compact', false);
    _noAnim      = await StorageService.loadBool('noAnim', false);
    _streak      = await StorageService.loadBool('streak', true);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> setColorScheme(AppColorScheme scheme) async {
    _colorScheme = scheme;
    await StorageService.saveColorScheme(scheme);
    notifyListeners();
  }

  Future<void> setPureBlack(bool v) async {
    _isPureBlack = v;
    await StorageService.savePureBlack(v);
    notifyListeners();
  }

  Future<void> setCompact(bool v) async {
    _compact = v;
    await StorageService.saveBool('compact', v);
    notifyListeners();
  }

  Future<void> setNoAnim(bool v) async {
    _noAnim = v;
    await StorageService.saveBool('noAnim', v);
    notifyListeners();
  }

  Future<void> setStreak(bool v) async {
    _streak = v;
    await StorageService.saveBool('streak', v);
    notifyListeners();
  }

  // ── Accent colors ──────────────────────────────────────────
  Color get accent1 {
    switch (_colorScheme) {
      case AppColorScheme.defaultScheme: return kIndigo;
      case AppColorScheme.ember:         return kRed;
      case AppColorScheme.forest:        return kGreen;
      case AppColorScheme.sunset:        return const Color(0xFFF59E0B);
    }
  }

  Color get accent2 {
    switch (_colorScheme) {
      case AppColorScheme.defaultScheme: return kPink;
      case AppColorScheme.ember:         return kOrange;
      case AppColorScheme.forest:        return kBlue;
      case AppColorScheme.sunset:        return kRed;
    }
  }

  Color get seedColor => accent1;

  List<Color> get accentGradient => [accent1, accent2];

  // ── Theme data ─────────────────────────────────────────────
  ThemeData get lightTheme => buildLightTheme(seedColor);
  ThemeData get darkTheme  => buildDarkTheme(seedColor, pureBlack: _isPureBlack);
}
