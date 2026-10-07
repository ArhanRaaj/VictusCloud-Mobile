import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SchedulesTab extends ConsumerWidget {
  final String serverId;

  const SchedulesTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Create Schedule'),
        icon: const Icon(Icons.schedule),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Restart $index', style: AppTypography.h4),
                        Switch(value: true, onChanged: (v) {}, activeColor: AppColors.textPrimary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Cron: 0 4 * * *', style: TextStyle(fontFamily: 'monospace')),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Next Run: in 5 hours', style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(icon: const Icon(Icons.play_arrow, color: AppColors.textPrimary), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.edit, color: AppColors.textPrimary), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, color: AppColors.textPrimary), onPressed: () {}),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
