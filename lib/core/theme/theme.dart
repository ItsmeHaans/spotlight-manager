import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeName {
  yellowLight,
  yellowDark,
  blueLight,
  blueDark,
  silverLight,
  silverDark,
  pinkLight,
  pinkDark,
}

class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color sidebar;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTitle;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.sidebar,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTitle,
  });
}

class AppThemes {
  static const yellowLight = AppColors(
    primary: Color(0xFFC9BE3F),
    secondary: Color(0xFFEDE9B8),
    background: Color(0xFFFBFBF2),
    sidebar: Color(0xFFEDE9B8),
    error: Color(0xFFFF5252),
    textPrimary: Color(0xFF2E2C1E),
    textSecondary: Color(0xFFFBFBF2),
    textTitle: Color(0xFF2E2C1E),
  );
  static const yellowDark = AppColors(
    primary: Color(0xFFC9BE3F),
    secondary: Color(0xFFEDE9B8),
    background: Color(0xFF2E2C1E),
    sidebar: Color(0xFFEDE9B8),
    error: Color(0xFFFF5252),
    textPrimary: Color(0xFF2E2C1E),
    textSecondary: Color(0xFFFBFBF2),
    textTitle: Color(0xFFFBFBF2),
  );

  static const blueLight = AppColors(
    primary: Color(0xFF445D82),
    secondary: Color(0xFF7C93B3),
    background: Color(0xFFF4F6F9),
    sidebar: Color(0xFF7C93B3),
    error: Color(0xFFFF5252),
    textPrimary: Color(0xFF1E2530),
    textSecondary: Color(0xFFF4F6F9),
    textTitle: Color(0xFF1E2530),
  );

  static const blueDark = AppColors(
    primary: Color(0xFF445D82),
    secondary: Color(0xFF7C93B3),
    background: Color(0xFF1E2530),
    sidebar: Color(0xFF7C93B3),
    error: Color(0xFFFF5252),
    textPrimary: Color(0xFF1E2530),
    textSecondary: Color(0xFFF4F6F9),
    textTitle: Color(0xFFF4F6F9),
  );

  static const silverLight = AppColors(
    primary: Color(0xFF6E7A85),
    secondary: Color(0xFFC7CDD3),
    background: Color(0xFFF5F6F7),
    sidebar: Color(0xFFC7CDD3),
    error: Color(0xFFFF6B6B),
    textPrimary: Color(0xFF2A2E33),
    textSecondary: Color(0xFFF5F6F7),
    textTitle: Color(0xFF2A2E33),
  );
  static const silverDark = AppColors(
    primary: Color(0xFF6E7A85),
    secondary: Color(0xFFC7CDD3),
    background: Color(0xFF2A2E33),
    sidebar: Color(0xFFC7CDD3),
    error: Color(0xFFFF6B6B),
    textPrimary: Color(0xFF2A2E33),
    textSecondary: Color(0xFFF5F6F7),
    textTitle: Color(0xFFF5F6F7),
  );

  static const pinkLight = AppColors(
    primary: Color(0xFFE0899C),
    secondary: Color(0xFFF2C6CE),
    background: Color(0xFFFBF6F5),
    sidebar: Color(0xFFF2C6CE),
    error: Color(0xFFFF5C7A),
    textPrimary: Color(0xFF2B2024),
    textSecondary: Color(0xFFFBF6F5),
    textTitle: Color(0xFF2B2024),
  );

  static const pinkDark = AppColors(
    primary: Color(0xFFE0899C),
    secondary: Color(0xFFF2C6CE),
    background: Color(0xFF2B2024),
    sidebar: Color(0xFFF2C6CE),
    error: Color(0xFFFF5C7A),
    textPrimary: Color(0xFF2B2024),
    textSecondary: Color(0xFFFBF6F5),
    textTitle: Color(0xFFFBF6F5),
  );

  static AppColors of(AppThemeName name) {
    switch (name) {
      case AppThemeName.yellowLight:
        return yellowLight;
      case AppThemeName.yellowDark:
        return yellowDark;
      case AppThemeName.blueLight:
        return blueLight;
      case AppThemeName.blueDark:
        return blueDark;
      case AppThemeName.silverLight:
        return silverLight;
      case AppThemeName.silverDark:
        return silverDark;
      case AppThemeName.pinkLight:
        return pinkLight;
      case AppThemeName.pinkDark:
        return pinkDark;
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
