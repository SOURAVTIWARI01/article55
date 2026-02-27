import 'package:flutter/material.dart';

/// Centralized color palette extracted from the design mockups.
class AppColors {
  AppColors._();

  // ─── Primary & Accent ─────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600
  static const Color primaryLight = Color(0xFF6366F1);   // Indigo-500
  static const Color primaryDark = Color(0xFF3730A3);    // Indigo-800
  static const Color accent = Color(0xFF8B5CF6);         // Violet-500
  static const Color accentLight = Color(0xFFA78BFA);    // Violet-400

  // ─── Backgrounds ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // ─── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF71747E);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Status ───────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Glass / Surface ──────────────────────────────────────
  static const Color glassLight = Color(0xB3FFFFFF);     // white 70%
  static const Color glassDark = Color(0xB31E293B);      // slate-800 70%
  static const Color glassBorderLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // ─── Gradients ────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFFE8E0F0),
      Color(0xFFD5CCE8),
      Color(0xFFE0D4EC),
      Color(0xFFEADDF0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient titleGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
