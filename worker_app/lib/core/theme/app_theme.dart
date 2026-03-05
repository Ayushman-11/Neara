import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.sora(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.brightIvory,
    letterSpacing: -0.3,
  );

  static TextStyle get titleLarge => GoogleFonts.sora(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.brightIvory,
    letterSpacing: -0.3,
  );

  static TextStyle get titleMedium => GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.brightIvory,
  );

  static TextStyle get titleSmall => GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.brightIvory,
  );

  static TextStyle get bodyLarge => GoogleFonts.sora(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.softMoonlight,
  );

  static TextStyle get bodyMedium => GoogleFonts.sora(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.softMoonlight,
  );

  static TextStyle get bodySmall => GoogleFonts.sora(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedFog,
  );

  static TextStyle get micro => GoogleFonts.sora(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedFog,
    letterSpacing: 1.5,
  );

  static TextStyle get label => GoogleFonts.sora(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.softMoonlight,
  );

  // Mono styles for prices/numbers
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.saffronAmber,
  );

  static TextStyle get monoMedium => GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.brightIvory,
  );

  static TextStyle get monoSmall => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.softMoonlight,
  );

  static TextStyle get chipLabel => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.brightIvory,
    letterSpacing: 1.2,
  );

  static TextStyle get heroAmount => GoogleFonts.jetBrainsMono(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.brightIvory,
    letterSpacing: -1,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnightNavy,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.saffronAmber,
        secondary: AppColors.liveTeal,
        surface: AppColors.warmCharcoal,
        error: AppColors.emergencyCrimson,
        onPrimary: AppColors.midnightNavy,
        onSecondary: AppColors.midnightNavy,
        onSurface: AppColors.brightIvory,
        onError: AppColors.brightIvory,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.midnightNavy,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.brightIvory),
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.brightIvory,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.warmCharcoal,
        selectedItemColor: AppColors.saffronAmber,
        unselectedItemColor: AppColors.mutedFog,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffronAmber,
          foregroundColor: AppColors.midnightNavy,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.saffronAmber,
          side: const BorderSide(color: AppColors.saffronAmber, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.saffronAmber,
          textStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevatedGraphite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mutedSteel),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mutedSteel),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.saffronAmber,
            width: 1.5,
          ),
        ),
        hintStyle: GoogleFonts.sora(fontSize: 14, color: AppColors.mutedFog),
        labelStyle: GoogleFonts.sora(
          fontSize: 14,
          color: AppColors.softMoonlight,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.warmCharcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.mutedSteel, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.mutedSteel,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.elevatedGraphite,
        selectedColor: AppColors.saffronAmber,
        labelStyle: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.softMoonlight,
        ),
        side: const BorderSide(color: AppColors.mutedSteel),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.micro,
      ),
    );
  }
}
