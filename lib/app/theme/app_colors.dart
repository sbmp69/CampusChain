import 'package:flutter/material.dart';

/// CampusChain "Obsidian Glass" color system
class AppColors {
  AppColors._();

  // ─── Surfaces ───
  static const Color surfaceDark = Color(0xFF0A0E1A);
  static const Color surfaceCard = Color(0xFF12162B);
  static const Color surfaceElevated = Color(0xFF1A1F38);
  static const Color surfaceOverlay = Color(0xFF0D1127);

  // ─── Glass ───
  static Color glassFill = Colors.white.withValues(alpha: 0.06);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.08);

  // ─── Accent: Primary (Purple) ───
  static const Color accentPrimary = Color(0xFF6C63FF);
  static const Color accentPrimaryEnd = Color(0xFFB24BF3);
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [accentPrimary, accentPrimaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Accent: Secondary (Cyan-Green) ───
  static const Color accentSecondary = Color(0xFF00D9FF);
  static const Color accentSecondaryEnd = Color(0xFF00FF94);
  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [accentSecondary, accentSecondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Accent: Gold (Reputation) ───
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentGoldEnd = Color(0xFFFFA500);
  static const LinearGradient gradientGold = LinearGradient(
    colors: [accentGold, accentGoldEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Token Colors ───
  static const Color tokenAcademic = Color(0xFF6C63FF);
  static const Color tokenUtility = Color(0xFF00D9FF);
  static const Color tokenImpact = Color(0xFF00FF94);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFFFFFFF);
  static Color textSecondary = Colors.white.withValues(alpha: 0.6);
  static Color textTertiary = Colors.white.withValues(alpha: 0.35);

  // ─── Status ───
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);

  // ─── Misc ───
  static Color divider = Colors.white.withValues(alpha: 0.08);
  static Color shimmerBase = Colors.white.withValues(alpha: 0.04);
  static Color shimmerHighlight = Colors.white.withValues(alpha: 0.1);
}
