import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/Theme/app_text_styles.dart'; // Imported to stylize the SnackBar text

extension ContextExtensions on BuildContext {
  // MediaQuery Utilities
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isSmallScreen => screenWidth < 360;

  // Theme Utilities
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Global Context SnackBar Engine
  void showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // Floating look looks much cleaner on premium dark themes
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12), // Clean fallback spacing structure
            Expanded(
              child: Text(
                message,
                // Using standard bodyMedium but forcing it to white to pop over the banner color
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Specialized Feedback Channels
  void showSuccess(String message) {
    showSnackBar(message, AppColors.success, Icons.check_circle_outline);
  }

  void showError(String message) {
    showSnackBar(message, AppColors.error, Icons.error_outline);
  }

  void showWarning(String message) {
    showSnackBar(message, AppColors.warning, Icons.warning_amber_outlined);
  }

  void showInfo(String message) {
    showSnackBar(message, AppColors.info, Icons.info_outline);
  }
}