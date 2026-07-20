import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeName { yellowNeon, blue, silver, pinkRose }

class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
  });
}

class AppThemes {
  static const yellowNeon = AppColors(
    primary: Color(0xFFF5E000),
    secondary: Color(0xFFFFF176),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFFF5252),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
  );

  static const blue = AppColors(
    primary: Color(0xFF2979FF),
    secondary: Color(0xFF82B1FF),
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    error: Color(0xFFFF5252),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA0A8B4),
  );

  static const silver = AppColors(
    primary: Color(0xFFC7C9CC),
    secondary: Color(0xFFE8E9EB),
    background: Color(0xFF1A1A1C),
    surface: Color(0xFF242426),
    error: Color(0xFFFF6B6B),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF9A9A9C),
  );

  static const pinkRose = AppColors(
    primary: Color(0xFFF5A3C7),
    secondary: Color(0xFFFCD3E3),
    background: Color(0xFF1B1216),
    surface: Color(0xFF241A1E),
    error: Color(0xFFFF5C7A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFC9A9B4),
  );

  static AppColors of(AppThemeName name) {
    switch (name) {
      case AppThemeName.yellowNeon:
        return yellowNeon;
      case AppThemeName.blue:
        return blue;
      case AppThemeName.silver:
        return silver;
      case AppThemeName.pinkRose:
        return pinkRose;
    }
  }
}

class AppTypography {
  static TextStyle get heading1 =>
      GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold);

  static TextStyle get heading2 =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get caption =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.normal);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
