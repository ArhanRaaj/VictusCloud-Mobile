import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class DatabasesTab extends ConsumerWidget {
  final String serverId;

  const DatabasesTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('New Database'),
        icon: const Icon(Icons.storage),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('s123_main_db', style: AppTypography.h4),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Host: db.victuscloud.com', style: AppTypography.bodySmall),
                    Text('Port: 3306', style: AppTypography.bodySmall),
                    Text('Username: u123_test', style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(text: 'View Password', onPressed: () {}),
                        const SizedBox(width: AppSpacing.sm),
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
