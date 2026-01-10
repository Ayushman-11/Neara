import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  const primaryBackground = Color(0xFF0B0F1A);
  const secondaryBackground = Color(0xFF121826);
  const emergencyAccent = Color(0xFFEF4444);

  final baseTextTheme = GoogleFonts.poppinsTextTheme(
    const TextTheme(bodyMedium: TextStyle(color: Color(0xFFE5E7EB))),
  );

  final colorScheme = const ColorScheme.dark(
    background: primaryBackground,
    surface: secondaryBackground,
    primary: Color(0xFF4F46E5),
    secondary: Color(0xFF06B6D4),
    error: emergencyAccent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: primaryBackground,
    textTheme: baseTextTheme.apply(
      bodyColor: const Color(0xFFE5E7EB),
      displayColor: const Color(0xFFE5E7EB),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE5E7EB),
      elevation: 0,
      centerTitle: true,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
  );
}
