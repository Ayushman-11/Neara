import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Fresh Professional Palette ──────────────────────────────
class AppPalette {
  AppPalette._();
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const teal500 = Color(0xFF14B8A6);
  static const teal50 = Color(0xFFF0FDFA);
  static const orange500 = Color(0xFFF97316);
  static const gray900 = Color(0xFF111827);
  static const gray700 = Color(0xFF374151);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray50 = Color(0xFFF9FAFB);
  static const white = Color(0xFFFFFFFF);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(bodyMedium: TextStyle(color: AppPalette.gray900)),
  );

  const colorScheme = ColorScheme.light(
    surface: AppPalette.white,
    primary: AppPalette.teal600,
    secondary: AppPalette.teal500,
    error: AppPalette.error,
    onPrimary: AppPalette.white,
    onSurface: AppPalette.gray900,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.gray50,
    textTheme: baseTextTheme.apply(
      bodyColor: AppPalette.gray900,
      displayColor: AppPalette.gray900,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppPalette.gray900,
      elevation: 0,
      centerTitle: true,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppPalette.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.teal600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
  );
}

// ── Gradients ───────────────────────────────────────────────
class AppGradients {
  static const primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppPalette.gray50, AppPalette.gray100],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.teal600, AppPalette.teal700],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.white, AppPalette.gray50],
  );

  static const agentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppPalette.white, AppPalette.teal50, Color(0xFFCCFBF1)],
  );
}
