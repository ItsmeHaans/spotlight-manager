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
  final String logoPath;
  final String dashboardPath;
  final String routinePath;
  final String shoplistPath;
  final String calendarPath;
  final String statisticsPath;
  final String goalPath;
  final String notesPath;
  final String financialPath;
  final String wishlistPath;
  final String arrowPath;
  final String homePath;
  final String inputPath;
  final String profilePath;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.sidebar,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTitle,
    required this.logoPath,
    required this.dashboardPath,
    required this.routinePath,
    required this.shoplistPath,
    required this.calendarPath,
    required this.statisticsPath,
    required this.goalPath,
    required this.notesPath,
    required this.financialPath,
    required this.wishlistPath,
    required this.arrowPath,
    required this.homePath,
    required this.inputPath,
    required this.profilePath,
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
    logoPath: 'assets/svg/yellowIcon.svg',
    dashboardPath: 'assets/svg/yellowDashboard.svg',
    routinePath: 'assets/svg/yellowRoutine.svg',
    shoplistPath: 'assets/svg/yellowShoplist.svg',
    calendarPath: 'assets/svg/yellowCalendar.svg',
    statisticsPath: 'assets/svg/yellowStatistics.svg',
    goalPath: 'assets/svg/yellowGoal.svg',
    notesPath: 'assets/svg/yellowNotes.svg',
    financialPath: 'assets/svg/yellowFinancial.svg',
    wishlistPath: 'assets/svg/yellowWishlist.svg',
    arrowPath: 'assets/svg/yellowArrow.svg',
    homePath: 'assets/svg/yellowHome.svg',
    inputPath: 'assets/svg/yellowInput.svg',
    profilePath: 'assets/svg/yellowProfile.svg',
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
    logoPath: 'assets/svg/yellowIcon.svg',
    dashboardPath: 'assets/svg/yellowDashboard.svg',
    routinePath: 'assets/svg/yellowRoutine.svg',
    shoplistPath: 'assets/svg/yellowShoplist.svg',
    calendarPath: 'assets/svg/yellowCalendar.svg',
    statisticsPath: 'assets/svg/yellowStatistics.svg',
    goalPath: 'assets/svg/yellowGoal.svg',
    notesPath: 'assets/svg/yellowNotes.svg',
    financialPath: 'assets/svg/yellowFinancial.svg',
    wishlistPath: 'assets/svg/yellowWishlist.svg',
    arrowPath: 'assets/svg/yellowArrow.svg',
    homePath: 'assets/svg/yellowHome.svg',
    inputPath: 'assets/svg/yellowInput.svg',
    profilePath: 'assets/svg/yellowProfile.svg',
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
    logoPath: 'assets/svg/blueIcon.svg',
    dashboardPath: 'assets/svg/blueDashboard.svg',
    routinePath: 'assets/svg/blueRoutine.svg',
    shoplistPath: 'assets/svg/blueShoplist.svg',
    calendarPath: 'assets/svg/blueCalendar.svg',
    statisticsPath: 'assets/svg/blueStatistics.svg',
    goalPath: 'assets/svg/blueGoal.svg',
    notesPath: 'assets/svg/blueNotes.svg',
    financialPath: 'assets/svg/blueFinancial.svg',
    wishlistPath: 'assets/svg/blueWishlist.svg',
    arrowPath: 'assets/svg/blueArrow.svg',
    homePath: 'assets/svg/blueHome.svg',
    inputPath: 'assets/svg/blueInput.svg',
    profilePath: 'assets/svg/blueProfile.svg',
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
    logoPath: 'assets/svg/blueIcon.svg',
    dashboardPath: 'assets/svg/blueDashboard.svg',
    routinePath: 'assets/svg/blueRoutine.svg',
    shoplistPath: 'assets/svg/blueShoplist.svg',
    calendarPath: 'assets/svg/blueCalendar.svg',
    statisticsPath: 'assets/svg/blueStatistics.svg',
    goalPath: 'assets/svg/blueGoal.svg',
    notesPath: 'assets/svg/blueNotes.svg',
    financialPath: 'assets/svg/blueFinancial.svg',
    wishlistPath: 'assets/svg/blueWishlist.svg',
    arrowPath: 'assets/svg/blueArrow.svg',
    homePath: 'assets/svg/blueHome.svg',
    inputPath: 'assets/svg/blueInput.svg',
    profilePath: 'assets/svg/blueProfile.svg',
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
    logoPath: 'assets/svg/silverIcon.svg',
    dashboardPath: 'assets/svg/silverDashboard.svg',
    routinePath: 'assets/svg/silverRoutine.svg',
    shoplistPath: 'assets/svg/silverShoplist.svg',
    calendarPath: 'assets/svg/silverCalendar.svg',
    statisticsPath: 'assets/svg/silverStatistics.svg',
    goalPath: 'assets/svg/silverGoal.svg',
    notesPath: 'assets/svg/silverNotes.svg',
    financialPath: 'assets/svg/silverFinancial.svg',
    wishlistPath: 'assets/svg/silverWishlist.svg',
    arrowPath: 'assets/svg/silverArrow.svg',
    homePath: 'assets/svg/silverHome.svg',
    inputPath: 'assets/svg/silverInput.svg',
    profilePath: 'assets/svg/silverProfile.svg',
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
    logoPath: 'assets/svg/silverIcon.svg',
    dashboardPath: 'assets/svg/silverDashboard.svg',
    routinePath: 'assets/svg/silverRoutine.svg',
    shoplistPath: 'assets/svg/silverShoplist.svg',
    calendarPath: 'assets/svg/silverCalendar.svg',
    statisticsPath: 'assets/svg/silverStatistics.svg',
    goalPath: 'assets/svg/silverGoal.svg',
    notesPath: 'assets/svg/silverNotes.svg',
    financialPath: 'assets/svg/silverFinancial.svg',
    wishlistPath: 'assets/svg/silverWishlist.svg',
    arrowPath: 'assets/svg/silverArrow.svg',
    homePath: 'assets/svg/silverHome.svg',
    inputPath: 'assets/svg/silverInput.svg',
    profilePath: 'assets/svg/silverProfile.svg',
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
    logoPath: 'assets/svg/pinkIcon.svg',
    dashboardPath: 'assets/svg/pinkDashboard.svg',
    routinePath: 'assets/svg/pinkRoutine.svg',
    shoplistPath: 'assets/svg/pinkShoplist.svg',
    calendarPath: 'assets/svg/pinkCalendar.svg',
    statisticsPath: 'assets/svg/pinkStatistics.svg',
    goalPath: 'assets/svg/pinkGoal.svg',
    notesPath: 'assets/svg/pinkNotes.svg',
    financialPath: 'assets/svg/pinkFinancial.svg',
    wishlistPath: 'assets/svg/pinkWishlist.svg',
    arrowPath: 'assets/svg/pinkArrow.svg',
    homePath: 'assets/svg/pinkHome.svg',
    inputPath: 'assets/svg/pinkInput.svg',
    profilePath: 'assets/svg/pinkProfile.svg',
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
    logoPath: 'assets/svg/pinkIcon.svg',
    dashboardPath: 'assets/svg/pinkDashboard.svg',
    routinePath: 'assets/svg/pinkRoutine.svg',
    shoplistPath: 'assets/svg/pinkShoplist.svg',
    calendarPath: 'assets/svg/pinkCalendar.svg',
    statisticsPath: 'assets/svg/pinkStatistics.svg',
    goalPath: 'assets/svg/pinkGoal.svg',
    notesPath: 'assets/svg/pinkNotes.svg',
    financialPath: 'assets/svg/pinkFinancial.svg',
    wishlistPath: 'assets/svg/pinkWishlist.svg',
    arrowPath: 'assets/svg/pinkArrow.svg',
    homePath: 'assets/svg/pinkHome.svg',
    inputPath: 'assets/svg/pinkInput.svg',
    profilePath: 'assets/svg/pinkProfile.svg',
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
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500);

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
