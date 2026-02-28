// ── theme/app_theme.dart ──────────────────────────────────────
// Single source of truth for every visual token in the app.
// Matches the HTML CSS variable design system exactly.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
//  LIGHT THEME COLORS  (--bg, --surface, etc.)
// ═══════════════════════════════════════════════════════════════
const Color kPageBg  = Color(0xFFD8D4CE); // body background
const Color kBg      = Color(0xFFFAFAF8); // --bg
const Color kSurface = Color(0xFFFFFFFF); // --surface
const Color kBorder  = Color(0x12000000); // --border rgba(0,0,0,0.07)
const Color kText    = Color(0xFF0F0F0F); // --text
const Color kTextMid = Color(0xFF555555); // --text-mid
const Color kTextDim = Color(0xFF999999); // --text-dim
const Color kHeroCard = Color(0xFF0F0F0F); // --hero-bg (light)

// ── Dark theme ──────────────────────────────────────────────
const Color kDarkPageBg  = Color(0xFF0A0A0A);
const Color kDarkBg      = Color(0xFF111111);
const Color kDarkSurface = Color(0xFF1C1C1E);
const Color kDarkBorder  = Color(0x17FFFFFF); // rgba(255,255,255,0.09)
const Color kDarkText    = Color(0xFFF5F5F5);
const Color kDarkTextMid = Color(0xFFABABAB);
const Color kDarkTextDim = Color(0xFF666666);
const Color kDarkHeroCard = Color(0xFF1C1C1E);

// ── Pure-Black theme ────────────────────────────────────────
const Color kPureBg      = Color(0xFF000000);
const Color kPureSurface = Color(0xFF111111);
const Color kPureBorder  = Color(0x12FFFFFF);
const Color kPureHeroCard = Color(0xFF111111);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  FIXED ACCENT + TASK COLORS  (same in all themes)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const Color kRed    = Color(0xFFFF4D4D); // --c-red
const Color kOrange = Color(0xFFFF8C00); // --c-orange
const Color kGreen  = Color(0xFF00C875); // --c-green
const Color kBlue   = Color(0xFF0EA5E9); // --c-blue
const Color kIndigo = Color(0xFF6366F1); // default --a1
const Color kPink   = Color(0xFFEC4899); // default --a2
const Color kYellow = Color(0xFFFBBF24);

// ═══════════════════════════════════════════════════════════════
//  SHADOWS
// ═══════════════════════════════════════════════════════════════
List<BoxShadow> get shadowSm => [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 4,
          offset: const Offset(0, 1)),
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1)),
    ];

List<BoxShadow> get shadowMd => [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4)),
    ];

// ═══════════════════════════════════════════════════════════════
//  TYPOGRAPHY
// ═══════════════════════════════════════════════════════════════
TextStyle heading({
  double size = 34,
  FontWeight weight = FontWeight.w800,
  Color color = kText,
  double letterSpacing = -1.0,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );

TextStyle body({
  double size = 14,
  FontWeight weight = FontWeight.w500,
  Color color = kText,
  double letterSpacing = 0,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );

// ═══════════════════════════════════════════════════════════════
//  CATEGORY HELPERS
// ═══════════════════════════════════════════════════════════════
Color categoryColor(String cat) {
  switch (cat) {
    case 'Work':     return kRed;
    case 'Shopping': return kIndigo;
    case 'Personal': return kGreen;
    case 'Health':   return kBlue;
    case 'Study':    return kOrange;
    default:         return kTextDim;
  }
}

Color categoryBg(String cat) {
  switch (cat) {
    case 'Work':     return const Color(0xFFFFF0F0);
    case 'Shopping': return const Color(0xFFF0F0FF);
    case 'Personal': return const Color(0xFFF0FFF6);
    case 'Health':   return const Color(0xFFFFF8E6);
    case 'Study':    return const Color(0xFFFFF5E6);
    default:         return const Color(0xFFF5F5F5);
  }
}

// Dark-mode category backgrounds (more subtle)
Color categoryBgDark(String cat) {
  switch (cat) {
    case 'Work':     return kRed.withValues(alpha: 0.15);
    case 'Shopping': return kIndigo.withValues(alpha: 0.15);
    case 'Personal': return kGreen.withValues(alpha: 0.15);
    case 'Health':   return kBlue.withValues(alpha: 0.15);
    case 'Study':    return kOrange.withValues(alpha: 0.15);
    default:         return const Color(0xFF2C2C2E);
  }
}

// ═══════════════════════════════════════════════════════════════
//  THEME DATA FACTORIES
// ═══════════════════════════════════════════════════════════════
ThemeData buildLightTheme(Color seedColor) {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: seedColor,
      surface: kSurface,
    ),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}

ThemeData buildDarkTheme(Color seedColor, {bool pureBlack = false}) {
  final bg      = pureBlack ? kPureBg      : kDarkBg;
  final surface = pureBlack ? kPureSurface : kDarkSurface;

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: seedColor,
      surface: surface,
    ),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
