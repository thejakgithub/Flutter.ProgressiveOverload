import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.w800,
          fontSize: 32,
          height: 1.1,
          color: AppColors.text,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          height: 1.15,
          color: AppColors.text,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: AppColors.text,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.text,
          height: 1.35,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.text,
          height: 1.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainer,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
