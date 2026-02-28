// ── pages/settings_page.dart ──────────────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? kDarkText : kText;
    final dimCol = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark ? kDarkSurface : kSurface;
    final borderCol = isDark ? kDarkBorder : kBorder;

    return Scaffold(
      backgroundColor: isDark ? kDarkBg : kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: surfaceCol,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Icon(Icons.arrow_back_rounded, color: textCol, size: 18),
            ),
          ),
        ),
        title: Text('Appearance', style: heading(size: 18, weight: FontWeight.w600, color: textCol, letterSpacing: -0.3)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Theme Mode ──
            Text('Theme', style: body(size: 13, weight: FontWeight.w600, color: dimCol)),
            const SizedBox(height: 12),
            Row(
              children: [
                _themeCard(context, themeProvider, 'Light', ThemeMode.light,
                    [const Color(0xFFF0EDE8), Colors.white], surfaceCol, borderCol, textCol, dimCol),
                const SizedBox(width: 10),
                _themeCard(context, themeProvider, 'Dark', ThemeMode.dark,
                    [const Color(0xFF1a1a1a), const Color(0xFF2a2a2a)], surfaceCol, borderCol, textCol, dimCol),
                const SizedBox(width: 10),
                _themeCard(context, themeProvider, 'System', ThemeMode.system,
                    [kIndigo, kPink], surfaceCol, borderCol, textCol, dimCol),
              ],
            ),

            const SizedBox(height: 32),

            // ── Accent Colors ──
            Text('Accent Color', style: body(size: 13, weight: FontWeight.w600, color: dimCol)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _accentSwatch(context, themeProvider, AppColorScheme.defaultScheme,
                    'Default', [kIndigo, kPink], borderCol, dimCol),
                _accentSwatch(context, themeProvider, AppColorScheme.ember,
                    'Ember', [kRed, kOrange], borderCol, dimCol),
                _accentSwatch(context, themeProvider, AppColorScheme.forest,
                    'Forest', [kGreen, kBlue], borderCol, dimCol),
                _accentSwatch(context, themeProvider, AppColorScheme.sunset,
                    'Sunset', [kOrange, kRed], borderCol, dimCol),
              ],
            ),

            const SizedBox(height: 32),

            // ── Toggles ──
            _toggleRow(
              'Pure black dark mode',
              themeProvider.isPureBlack,
              (val) => themeProvider.setPureBlack(val),
              textCol, borderCol,
            ),
          ].animate(interval: 50.ms).fade(duration: 300.ms).slideY(begin: 0.08, duration: 300.ms, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _themeCard(BuildContext context, ThemeProvider provider,
      String label, ThemeMode mode, List<Color> previewColors,
      Color surface, Color border, Color textCol, Color dimCol) {
    final isSelected = provider.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? kIndigo.withValues(alpha: 0.05) : surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? kIndigo : border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: previewColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: body(
                  size: 11,
                  weight: FontWeight.w600,
                  color: isSelected ? kIndigo : dimCol,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accentSwatch(BuildContext context, ThemeProvider provider,
      AppColorScheme scheme, String name, List<Color> gradientColors,
      Color border, Color dimCol) {
    final isSelected = provider.colorScheme == scheme;
    return GestureDetector(
      onTap: () => provider.setColorScheme(scheme),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSelected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: kText, width: 3)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: body(size: 10, weight: FontWeight.w600, color: dimCol)),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool val, ValueChanged<bool> onChanged,
      Color textCol, Color borderCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderCol)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: body(size: 14, color: kTextMid)),
          CupertinoSwitch(
            value: val,
            onChanged: onChanged,
            activeTrackColor: kIndigo,
          ),
        ],
      ),
    );
  }
}
