import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';

class SettingsTab extends ConsumerWidget {
  final String serverId;

  const SettingsTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Server Settings', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SFTP Details', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSftpRow(context, 'Host', 'sftp.victuscloud.com'),
                  _buildSftpRow(context, 'Port', '2022'),
                  _buildSftpRow(context, 'Username', 'user.1234abcd'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rename Server', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  const AppTextField(
                    hintText: 'New Server Name',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: 'Save Name',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danger Zone', style: AppTypography.h4.copyWith(color: AppColors.error)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Reinstalling your server will stop it, and then re-run the installation script that initially set it up. Some files may be deleted or modified during this process.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: 'Reinstall Server',
                    onPressed: () {
                      _showReinstallDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSftpRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Row(
            children: [
              Text(value, style: AppTypography.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
                onPressed: () {
                  // Copy to clipboard
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReinstallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: 'Reinstall Server?',
          content: 'Are you sure you want to reinstall this server? This action may be destructive.',
          actions: [
            AppButton(
              text: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              text: 'Reinstall',
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger reinstall
              },
            ),
          ],
        );
      },
    );
  }
}
