import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // --- Core Branded & Accent Palette ---
  static const Color background = Color(0xFF0D0F17); // Updated base dark background
  static const Color surface = Color(0xFF14161D);
  static const Color primary = Color(0xFFFFCC00); // Main Amber Accent
  static const Color primaryGold = Color(0xFFFFC72C);
  static const Color primaryGoldGlow = Color(0x33FFC72C);

  // --- Secondary & Special Accents ---
  static const Color primaryPurple = Color(0xFF9D61FF);
  static const Color primaryAccent = Color(0xFF9D61FF);
  static const Color accentBlue = Color(0xFF007AFF);

  // --- Gamification & Ranking Accents ---
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color silverAccent = Color(0xFFC0C0C0);
  static const Color bronzeAccent = Color(0xFFCD7F32);
  static const Color publicGreen = Color(0xFF2ECC71);
  static const Color privateRed = Color(0xFFE74C3C);

  // --- Linear Gradients ---
  static const List<Color> secondaryGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
  ];

  // --- Cards & Surfaces ---
  static const Color cardBackground = Color(0xFF161926); // Updated card background
  static const Color cardBackgroundAlt = Color(0xFF1B1E2B);
  static const Color cardBorder = Color(0x12FFFFFF);
  static const Color borderOutline = Color(0xFF262B3E);
  static const Color divider = Color(0x12FFFFFF);

  // --- Inputs & Controls ---
  static const Color inputBackground = Color(0xFF0F0F10);
  static const Color inputBorder = Color(0xFF2C2C2E);

  // --- Typography ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x99FFFFFF); // 60% opacity
  static const Color textMuted = Color(0x66FFFFFF);     // 40% opacity

  // --- Feedback & Status (Gamified Dark Mode) ---
  static const Color success = Color(0xFF4CD964); // Crisp Emerald
  static const Color error = Color(0xFFFF3B30);   // Clear Crimson
  static const Color warning = Color(0xFFFF9500); // Sharp Orange
  static const Color info = Color(0xFF5AC8FA);    // Electric Cyan


}