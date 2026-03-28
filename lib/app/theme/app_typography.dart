import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// CampusChain typography system
class AppTypography {
  AppTypography._();

  static TextStyle _spaceGrotesk({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _inter({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ─── Display ───
  static TextStyle displayLarge = _spaceGrotesk(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.5,
  );

  static TextStyle displayMedium = _spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -1.0,
  );

  static TextStyle displaySmall = _spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ─── Headings ───
  static TextStyle headlineLarge = _spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle headlineMedium = _spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle headlineSmall = _spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // ─── Body ───
  static TextStyle bodyLarge = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ─── Labels ───
  static TextStyle labelLarge = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ─── Special ───
  static TextStyle tokenValue = _spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.0,
  );

  static TextStyle statNumber = _spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
}
