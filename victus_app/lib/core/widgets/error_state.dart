import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            AppSpacing.verticalMedium,
            Text(title, style: AppTypography.title, textAlign: TextAlign.center),
            AppSpacing.verticalSmall,
            Text(
              message,
              style: AppTypography.body.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalLarge,
            if (onRetry != null || onReport != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null)
                    VictusPrimaryButton(text: 'Retry', onPressed: onRetry),
                  if (onReport != null) ...[
                    AppSpacing.horizontalMedium,
                    VictusSecondaryButton(text: 'Report', onPressed: onReport),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
