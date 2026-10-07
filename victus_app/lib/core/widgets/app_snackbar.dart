import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';

class AppSnackbar {
  static void _show(BuildContext context, String message, IconData icon) {
    final overlay = ScaffoldMessenger.of(context);
    overlay.hideCurrentSnackBar();
    overlay.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white),
            AppSpacing.horizontalMedium,
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void show(BuildContext context, String message) {
    showInfo(context, message);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Icons.info_outline);
  }
}
