import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    required this.title,
    String? message,
    String? content,
    this.onConfirm,
    this.onCancel,
    this.actions,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  }) : message = message ?? content ?? '',
       assert(actions != null || (onConfirm != null && onCancel != null));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: AppSpacing.paddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDestructive) ...[
              const Icon(Icons.warning_amber_rounded, color: AppColors.white, size: 32),
              AppSpacing.verticalMedium,
            ],
            Text(title, style: AppTypography.title),
            if (message.isNotEmpty) ...[
              AppSpacing.verticalSmall,
              Text(message, style: AppTypography.body.copyWith(color: AppColors.grey)),
            ],
            AppSpacing.verticalLarge,
            if (actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: VictusSecondaryButton(
                      text: cancelText,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                  AppSpacing.horizontalMedium,
                  Expanded(
                    child: isDestructive
                      ? VictusDangerButton(text: confirmText, onPressed: onConfirm ?? () {})
                      : VictusPrimaryButton(text: confirmText, onPressed: onConfirm ?? () {}),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
