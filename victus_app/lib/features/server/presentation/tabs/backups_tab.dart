import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';

class BackupsTab extends ConsumerWidget {
  final String serverId;

  const BackupsTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBackupDialog(context),
        label: const Text('Create Backup'),
        icon: const Icon(Icons.add),
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
                        Text('Backup ${index + 1}', style: AppTypography.h4),
                        Icon(index == 0 ? Icons.lock : Icons.lock_open, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Size: 1.2 GB', style: AppTypography.bodySmall),
                    Text('Created: 2 days ago', style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(icon: const Icon(Icons.download, color: AppColors.textPrimary), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.restore, color: AppColors.textPrimary), onPressed: () => _showRestoreDialog(context)),
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

  void _showCreateBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: 'Create Backup',
          content: 'Specify backup details below.',
          actions: [
            AppButton(text: 'Cancel', onPressed: () => Navigator.of(context).pop()),
            AppButton(text: 'Create', onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: 'Restore Backup',
          content: 'Restoring will stop the server and overwrite files. Continue?',
          actions: [
            AppButton(text: 'Cancel', onPressed: () => Navigator.of(context).pop()),
            AppButton(text: 'Restore', onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}
