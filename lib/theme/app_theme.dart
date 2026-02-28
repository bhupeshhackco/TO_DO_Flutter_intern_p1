// ── theme/app_theme.dart ──────────────────────────────────────
// Single source of truth for every visual token in the app.
// import this file from every widget/page.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════
const Color kBg       = Color(0xFFFAFAF8);
const Color kSurface  = Color(0xFFFFFFFF);
const Color kBorder   = Color(0x12000000);
const Color kText     = Color(0xFF0F0F0F);
const Color kTextMid  = Color(0xFF555555);
const Color kTextDim  = Color(0xFF999999);

// Accents
const Color kRed    = Color(0xFFFF4D4D);
const Color kOrange = Color(0xFFFF8C00);
const Color kGreen  = Color(0xFF00C875);
const Color kIndigo = Color(0xFF6366F1);
const Color kPink   = Color(0xFFEC4899);
const Color kBlue   = Color(0xFF0EA5E9);
const Color kYellow = Color(0xFFFBBF24);

// Page scaffold
const Color kPageBg   = Color(0xFFF0EDE8);
const Color kHeroCard = Color(0xFF0F0F0F);

// Dark‑mode overrides
const Color kDarkBg      = Color(0xFF121212);
const Color kDarkSurface = Color(0xFF1E1E1E);
const Color kDarkBorder  = Color(0x1AFFFFFF);
const Color kDarkText    = Color(0xFFF5F5F5);
const Color kDarkTextMid = Color(0xFFAAAAAA);
const Color kDarkTextDim = Color(0xFF666666);

// ═══════════════════════════════════════════════════════════════
//  GRADIENTS
// ═══════════════════════════════════════════════════════════════
const heroGradient = LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFFFF4D4D)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const donutGradient = LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ═══════════════════════════════════════════════════════════════
//  SHADOWS
// ═══════════════════════════════════════════════════════════════
List<BoxShadow> get shadowSm => [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 1)),
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 1)),
    ];

List<BoxShadow> get shadowMd => [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4)),
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1)),
    ];

// ═══════════════════════════════════════════════════════════════
//  TYPOGRAPHY (Google Fonts)
// ═══════════════════════════════════════════════════════════════
// Display / Headings  — Space Grotesk (widely available fallback for ClashDisplay)
TextStyle heading({
  double size = 34,
  FontWeight weight = FontWeight.w700,
  Color color = kText,
  double letterSpacing = -1.0,
}) =>
    GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );

// Body / Labels — Plus Jakarta Sans
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

// ═══════════════════════════════════════════════════════════════
//  THEME DATA
// ═══════════════════════════════════════════════════════════════
ThemeData buildLightTheme(Color seedColor) {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kPageBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: kIndigo,
      surface: kSurface,
    ),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    useMaterial3: true,
    cardTheme: CardThemeData(
      color: kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}

ThemeData buildDarkTheme(Color seedColor, {bool pureBlack = false}) {
  final bg = pureBlack ? Colors.black : kDarkBg;
  final surface = pureBlack ? const Color(0xFF111111) : kDarkSurface;

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: kIndigo,
      surface: surface,
    ),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    useMaterial3: true,
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kDarkBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
