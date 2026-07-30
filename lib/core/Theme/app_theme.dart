import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      
      // Complete Theme Color Mapping
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,        // Amber / Yellow accent
        secondary: AppColors.primary,      
        error: AppColors.error,
        surface: AppColors.background,     // Pure dark background base
        surfaceContainer: AppColors.surface, // Container card base color
      ),

      // Global App Scaffold Configuration
      scaffoldBackgroundColor: AppColors.background,

      // Global AppBar System Styling
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.headlineSmall,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // White status icons over dark base
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Reusable Custom Elevated Button Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background, // Text pops in dark over yellow
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),

      // Reusable Outlined Action Button Styles
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      // Minimal Secondary Action Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      // Global Input Box Decorations (Matches your Exact Design Snippet)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Default idle styling 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        // Active focusing styling
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        // Structural validation alert styling
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.labelLarge,
        labelStyle: AppTextStyles.bodyMedium,
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // High-End Surface Card Specifications
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.inputBorder),
        ),
      ),

      // Premium Lower Navigation Controls Configuration
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Clean Section Partition Separators
      dividerTheme: const DividerThemeData(
        color: AppColors.inputBorder,
        thickness: 1,
        space: 0,
      ),
    );
  }
}