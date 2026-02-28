// ── pages/settings_page.dart ───────────────────────────────────
// Rebuilt as the Appearance screen — 4th tab in the IndexedStack.
// Matches HTML #s-appear: theme cards, accent swatches, toggle rows.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  /// Called when the user taps the back (←) button to return to Home tab.
  final VoidCallback? onBack;

  const SettingsPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final tp     = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol   = isDark ? kDarkText    : kText;
    final dimCol    = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark
        ? (tp.isPureBlack ? kPureSurface : kDarkSurface)
        : kSurface;
    final borderCol  = isDark ? kDarkBorder : kBorder;
    final accent1    = tp.accent1;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: onBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: surfaceCol,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                        boxShadow: shadowSm,
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: textCol, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Appearance',
                      style: heading(size: 26, color: textCol, letterSpacing: -0.8)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ══════════════════ THEME ══════════════════
                  _sectionLabel('Theme', dimCol),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _themeCard(
                        context, tp, 'Light', ThemeMode.light,
                        const LinearGradient(
                          colors: [Color(0xFFFAFAF8), Color(0xFFF0EDE8)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        surfaceCol, borderCol, textCol, dimCol, accent1,
                      ),
                      const SizedBox(width: 10),
                      _themeCard(
                        context, tp, 'Dark', ThemeMode.dark,
                        const LinearGradient(
                          colors: [Color(0xFF1C1C1E), Color(0xFF0A0A0A)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        surfaceCol, borderCol, textCol, dimCol, accent1,
                      ),
                      const SizedBox(width: 10),
                      _themeCard(
                        context, tp, 'Pure Black',
                        // "Pure Black" maps to dark + isPureBlack = true
                        // We treat ThemeMode.system as "pure black" selection signal
                        ThemeMode.system,
                        const LinearGradient(
                          colors: [Color(0xFF111111), Color(0xFF000000)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        surfaceCol, borderCol, textCol, dimCol, accent1,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ══════════════════ ACCENT ══════════════════
                  _sectionLabel('Accent Color', dimCol),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _accentSwatch(context, tp, AppColorScheme.defaultScheme,
                          'Default', const [Color(0xFF6366F1), Color(0xFFEC4899)], textCol, dimCol),
                      _accentSwatch(context, tp, AppColorScheme.ember,
                          'Ember',   const [Color(0xFFFF4D4D), Color(0xFFFF8C00)], textCol, dimCol),
                      _accentSwatch(context, tp, AppColorScheme.forest,
                          'Forest',  const [Color(0xFF00C875), Color(0xFF0EA5E9)], textCol, dimCol),
                      _accentSwatch(context, tp, AppColorScheme.sunset,
                          'Sunset',  const [Color(0xFFF59E0B), Color(0xFFEF4444)], textCol, dimCol),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ══════════════════ TOGGLES ══════════════════
                  _sectionLabel('Preferences', dimCol),
                  const SizedBox(height: 4),

                  _toggleRow(
                    'Pure black dark mode',
                    'Switches to absolute black theme',
                    tp.isPureBlack,
                    (v) {
                      tp.setPureBlack(v);
                      if (v && tp.themeMode != ThemeMode.dark &&
                          tp.themeMode != ThemeMode.system) {
                        tp.setThemeMode(ThemeMode.dark);
                      }
                    },
                    textCol, dimCol, borderCol, accent1,
                  ),

                  _toggleRow(
                    'Compact task view',
                    'Smaller cards, less padding',
                    tp.compact,
                    tp.setCompact,
                    textCol, dimCol, borderCol, accent1,
                  ),

                  _toggleRow(
                    'Reduce animations',
                    'Turns off confetti & transitions',
                    tp.noAnim,
                    tp.setNoAnim,
                    textCol, dimCol, borderCol, accent1,
                  ),

                  _toggleRow(
                    'Show completion streak',
                    'Keeps you coming back daily',
                    tp.streak,
                    tp.setStreak,
                    textCol, dimCol, borderCol, accent1,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color dim) => Text(
        text.toUpperCase(),
        style: body(
          size: 10,
          weight: FontWeight.w800,
          color: dim,
          letterSpacing: 0.12 * 10,
        ),
      );

  // ── Theme preview card ──────────────────────────────────────
  Widget _themeCard(
    BuildContext context,
    ThemeProvider tp,
    String label,
    ThemeMode mode,
    Gradient gradient,
    Color surface, Color border, Color textCol, Color dimCol, Color accent,
  ) {
    // "Pure Black" (ThemeMode.system) is selected when dark + isPureBlack
    final isPure = (mode == ThemeMode.system);
    final isSelected = isPure
        ? (tp.themeMode == ThemeMode.dark && tp.isPureBlack)
        : (tp.themeMode == mode && !tp.isPureBlack);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isPure) {
            tp.setThemeMode(ThemeMode.dark);
            tp.setPureBlack(true);
          } else {
            tp.setThemeMode(mode);
            if (mode == ThemeMode.light) tp.setPureBlack(false);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.08)
                : surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accent : border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: shadowSm,
          ),
          child: Column(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: body(
                  size: 11, weight: FontWeight.w700,
                  color: isSelected ? accent : dimCol,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Accent swatch ───────────────────────────────────────────
  Widget _accentSwatch(
    BuildContext context,
    ThemeProvider tp,
    AppColorScheme scheme,
    String name,
    List<Color> colors,
    Color textCol,
    Color dimCol,
  ) {
    final isSelected = tp.colorScheme == scheme;
    return GestureDetector(
      onTap: () => tp.setColorScheme(scheme),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSelected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(color: textCol, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6))]
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(name,
              style: body(
                size: 10, weight: FontWeight.w700,
                color: isSelected ? textCol : dimCol,
              )),
        ],
      ),
    );
  }

  // ── Toggle row ──────────────────────────────────────────────
  Widget _toggleRow(
    String label,
    String desc,
    bool value,
    ValueChanged<bool> onChanged,
    Color textCol, Color dimCol, Color borderCol, Color accent, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: borderCol, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: body(size: 14, weight: FontWeight.w500, color: kTextMid)),
                const SizedBox(height: 2),
                Text(desc,
                    style: body(size: 11, color: dimCol)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accent,
          ),
        ],
      ),
    );
  }
}
