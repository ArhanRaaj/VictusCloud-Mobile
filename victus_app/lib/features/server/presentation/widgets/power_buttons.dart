import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/widgets/app_button.dart';
import 'package:victus_app/core/widgets/app_dialog.dart';
import 'package:victus_app/features/server/presentation/providers/server_detail_provider.dart';

class PowerButtons extends ConsumerWidget {
  final String serverId;

  const PowerButtons({Key? key, required this.serverId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverStatusProvider(serverId)).valueOrNull ?? 'offline';

    final bool canStart = status == 'offline';
    final bool canStop = status == 'running' || status == 'starting';
    final bool canKill = status == 'running' || status == 'starting' || status == 'stopping';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceVariant,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPowerBtn(
            context: context,
            icon: Icons.play_arrow,
            label: 'Start',
            enabled: canStart,
            onPressed: () => ref.read(serverDetailNotifierProvider).sendPowerAction(serverId, 'start'),
          ),
          _buildPowerBtn(
            context: context,
            icon: Icons.stop,
            label: 'Stop',
            enabled: canStop,
            onPressed: () => ref.read(serverDetailNotifierProvider).sendPowerAction(serverId, 'stop'),
          ),
          _buildPowerBtn(
            context: context,
            icon: Icons.refresh,
            label: 'Restart',
            enabled: canStop, // usually can restart if running
            onPressed: () => ref.read(serverDetailNotifierProvider).sendPowerAction(serverId, 'restart'),
          ),
          _buildPowerBtn(
            context: context,
            icon: Icons.close,
            label: 'Kill',
            enabled: canKill,
            isDanger: true,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AppDialog(
                  title: 'Kill Server',
                  content: 'Are you sure you want to forcibly stop this server? This may lead to data corruption.',
                  primaryActionText: 'Kill',
                  onPrimaryAction: () {
                    ref.read(serverDetailNotifierProvider).sendPowerAction(serverId, 'kill');
                    Navigator.pop(ctx);
                  },
                  secondaryActionText: 'Cancel',
                  onSecondaryAction: () => Navigator.pop(ctx),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPowerBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    bool isDanger = false,
  }) {
    return AppButton.outlined(
      onPressed: enabled ? onPressed : null,
      text: label,
      icon: icon,
      borderColor: isDanger ? Colors.red : AppColors.border,
      textColor: isDanger && enabled ? Colors.red : (enabled ? AppColors.textPrimary : AppColors.textSecondary),
    );
  }
}
