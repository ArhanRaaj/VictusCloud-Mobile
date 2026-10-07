import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class StartupTab extends ConsumerWidget {
  final String serverId;

  const StartupTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Startup Command', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('java -Xms128M -Xmx{{SERVER_MEMORY}}M -jar {{SERVER_JARFILE}}', style: TextStyle(fontFamily: 'monospace', color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Docker Image', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  const AppTextField(
                    hintText: 'ghcr.io/pterodactyl/yolks:java_17',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Environment Variables', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          _buildEnvVarCard('SERVER_JARFILE', 'server.jar'),
          _buildEnvVarCard('BUILD_NUMBER', 'latest'),
        ],
      ),
    );
  }

  Widget _buildEnvVarCard(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key, style: AppTypography.h4),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                hintText: value,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(text: 'Update Variable', onPressed: () {})
            ],
          ),
        ),
      ),
    );
  }
}
