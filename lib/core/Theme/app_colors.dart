import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Theme Branded Palette
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color primary = Color(0xFFFFCC00); // Amber Accent
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  
  // Custom Specialized Inputs Infrastructure 
  static const Color inputBackground = Color(0xFF0F0F10);
  static const Color inputBorder = Color(0xFF2C2C2E);

  // System Feedback Channels (Gamified Dark Mode Compliant)
  static const Color success = Color(0xFF4CD964); // Crisp, readable emerald green
  static const Color error = Color(0xFFFF3B30);   // Punchy, clear warning crimson
  static const Color warning = Color(0xFFFF9500); // Sharp neon orange for alerts
  static const Color info = Color(0xFF5AC8FA);    // Sleek electric cyan for status tokens
}