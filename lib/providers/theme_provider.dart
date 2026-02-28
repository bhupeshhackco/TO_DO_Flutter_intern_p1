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
  ThemeMode _themeMode = ThemeMode.system;
  AppColorScheme _colorScheme = AppColorScheme.defaultScheme;
  bool _isPureBlack = false;

  ThemeMode get themeMode => _themeMode;
  AppColorScheme get colorScheme => _colorScheme;
  bool get isPureBlack => _isPureBlack;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _themeMode = await StorageService.loadThemeMode();
    _colorScheme = await StorageService.loadColorScheme();
    _isPureBlack = await StorageService.loadPureBlack();
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

  Future<void> setPureBlack(bool isPure) async {
    _isPureBlack = isPure;
    await StorageService.savePureBlack(isPure);
    notifyListeners();
  }

  Color get seedColor {
    switch (_colorScheme) {
      case AppColorScheme.defaultScheme:
        return kIndigo;
      case AppColorScheme.ember:
        return kRed;
      case AppColorScheme.forest:
        return kGreen;
      case AppColorScheme.sunset:
        return kOrange;
    }
  }

  // Gradient pair for the current accent scheme
  List<Color> get accentGradient {
    switch (_colorScheme) {
      case AppColorScheme.defaultScheme:
        return [kIndigo, kPink];
      case AppColorScheme.ember:
        return [kRed, kOrange];
      case AppColorScheme.forest:
        return [kGreen, kBlue];
      case AppColorScheme.sunset:
        return [kOrange, kRed];
    }
  }

  ThemeData get lightTheme => buildLightTheme(seedColor);

  ThemeData get darkTheme => buildDarkTheme(seedColor, pureBlack: _isPureBlack);
}
