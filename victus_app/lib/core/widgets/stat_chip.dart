import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.white),
          AppSpacing.horizontalSmall,
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey)),
          AppSpacing.horizontalSmall,
          Text(value, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.white)),
        ],
      ),
    );
  }
}
