import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme getDarkTextTheme() {
    return GoogleFonts.interTextTheme(
      _baseTextTheme(AppColors.textPrimary, AppColors.textSecondary),
    );
  }

  static TextTheme getLightTextTheme() {
    return GoogleFonts.interTextTheme(
      _baseTextTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
    );
  }

  static TextTheme _baseTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: -0.25, height: 1.12),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: 0, height: 1.16),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: 0, height: 1.22),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0, height: 1.25),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0, height: 1.29),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0, height: 1.33),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0, height: 1.27),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.15, height: 1.50),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.1, height: 1.43),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor, letterSpacing: 0.1, height: 1.43),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: primaryColor, letterSpacing: 0.5, height: 1.33),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondaryColor, letterSpacing: 0.5, height: 1.45),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primaryColor, letterSpacing: 0.15, height: 1.50),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primaryColor, letterSpacing: 0.25, height: 1.43),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondaryColor, letterSpacing: 0.4, height: 1.33),
    );
  }

  // Static style aliases used across widgets
  static TextStyle get h1 => const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 => const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h3 => const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h4 => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get body => const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get body1 => const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get body2 => const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get bodyMedium => const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get bodySmall => const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get caption => const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get label => const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get subtitle => const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get subtitle1 => const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle get title => const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get button => const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get monospace => const TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textPrimary);

  // Custom text styles
  static TextStyle consoleMono(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jetbrainsMono(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      height: 1.5,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.background : AppColors.lightBackground,
      letterSpacing: 0.1,
    );
  }

  static TextStyle chipText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle tabLabel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      height: 1.5,
    );
  }

  static TextStyle cardSubtitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
      height: 1.43,
    );
  }
}
