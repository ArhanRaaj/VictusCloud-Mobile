import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';
import 'package:victus_app/core/widgets/app_card.dart';
import 'package:victus_app/core/widgets/status_indicator.dart';
import 'package:victus_app/core/widgets/app_button.dart';
import 'package:victus_app/core/widgets/app_snackbar.dart';
import 'package:victus_app/core/utils/haptics.dart';
import 'package:victus_app/features/server/data/models/ptero_server.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import '../../data/models/power_action.dart';
import '../providers/dashboard_provider.dart';
import 'resource_bar.dart';

class ServerCard extends ConsumerWidget {
  final PteroServer server;
  final ServerResources? resources;

  const ServerCard({
    Key? key,
    required this.server,
    this.resources,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Haptics.light();
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.show(context, 'Copied to clipboard');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = resources?.currentState ?? 'offline';
    final isRunning = status == 'running';
    final isOffline = status == 'offline';

    // Simplified parsing of resources for display
    final cpuUsage = resources?.cpuAbsolute ?? 0.0;
    final memUsage = (resources?.memoryBytes ?? 0) / (1024 * 1024);
    final diskUsage = (resources?.diskBytes ?? 0) / (1024 * 1024);
    
    final memLimit = server.limits.memory;
    final diskLimit = server.limits.disk;

    return AppCard(
      onTap: () {
        Haptics.selection();
        // Navigate to server detail
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                server.name,
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              StatusIndicator(status: _mapStatus(status), showLabel: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minecraft', // Assuming a game label
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(context, '192.168.1.1:25565'), // Mock IP
                child: Text(
                  '192.168.1.1:25565',
                  style: AppTypography.monospace.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (resources != null) ...[
            ResourceBar(
              label: 'CPU',
              progress: cpuUsage / 100,
              detailText: '${cpuUsage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: AppSpacing.sm),
            ResourceBar(
              label: 'RAM',
              progress: memLimit > 0 ? memUsage / memLimit : 0,
              detailText: '${memUsage.toInt()} MB / ${memLimit} MB',
            ),
            const SizedBox(height: AppSpacing.sm),
            ResourceBar(
              label: 'Disk',
              progress: diskLimit > 0 ? diskUsage / diskLimit : 0,
              detailText: '${diskUsage.toInt()} MB / ${diskLimit} MB',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              if (isOffline)
                Expanded(
                  child: AppButton.outlined(
                    text: 'Start',
                    onPressed: () {
                      Haptics.medium();
                      ref.read(dashboardStateProvider.notifier).sendPowerAction(server.identifier, PowerAction.start);
                    },
                  ),
                ),
              if (isRunning) ...[
                Expanded(
                  child: AppButton.outlined(
                    text: 'Restart',
                    onPressed: () {
                      Haptics.medium();
                      ref.read(dashboardStateProvider.notifier).sendPowerAction(server.identifier, PowerAction.restart);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton.outlined(
                    text: 'Stop',
                    onPressed: () {
                      Haptics.medium();
                      ref.read(dashboardStateProvider.notifier).sendPowerAction(server.identifier, PowerAction.stop);
                    },
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  // Helper to map Pterodactyl status string to StatusIndicator enum
  dynamic _mapStatus(String status) {
    // Return enum value expected by StatusIndicator (mocking since enum definition is in core)
    // Needs to match the actual enum in package:victus_app/core/widgets/status_indicator.dart
    switch (status) {
      case 'running':
        return 'running';
      case 'starting':
        return 'starting';
      case 'stopping':
        return 'stopping';
      default:
        return 'offline';
    }
  }
}
