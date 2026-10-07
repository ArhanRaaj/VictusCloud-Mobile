import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/widgets/app_card.dart';
import 'package:victus_app/core/theme/app_typography.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final String? detailText;
  final bool hasChart;
  final bool hasProgressBar;
  final double progress;

  const StatCard({
    Key? key,
    required this.title,
    required this.currentValue,
    this.detailText,
    this.hasChart = false,
    this.hasProgressBar = false,
    this.progress = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.subtitle1.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(currentValue, style: AppTypography.h2),
                if (detailText != null) ...[
                  const SizedBox(width: 8),
                  Text(detailText!, style: AppTypography.body2.copyWith(color: AppColors.textTertiary)),
                ]
              ],
            ),
            if (hasProgressBar) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
              ),
            ],
            if (hasChart) ...[
              const SizedBox(height: 16),
              // Placeholder for fl_chart
              Container(
                height: 100,
                color: AppColors.surfaceVariant,
                alignment: Alignment.center,
                child: const Text('Chart visualization', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
