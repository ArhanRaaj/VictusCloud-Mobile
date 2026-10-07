import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_spacing.dart';
import 'package:victus_app/core/utils/haptics.dart';
import 'package:victus_app/core/widgets/app_snackbar.dart';
import 'package:victus_app/core/widgets/status_indicator.dart';
import 'package:victus_app/features/server/presentation/providers/server_detail_provider.dart';
import 'package:victus_app/features/server/presentation/widgets/console_output.dart';
import 'package:victus_app/features/server/presentation/widgets/command_input.dart';
import 'package:victus_app/features/server/presentation/widgets/power_buttons.dart';

class ConsoleTab extends ConsumerStatefulWidget {
  final String serverId;

  const ConsoleTab({Key? key, required this.serverId}) : super(key: key);

  @override
  ConsumerState<ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends ConsumerState<ConsoleTab> {
  @override
  void initState() {
    super.initState();
    // Connect to the console WebSocket when tab is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serverDetailNotifierProvider(widget.serverId).notifier).connectConsole(widget.serverId);
    });
  }

  @override
  void dispose() {
    // Disconnect when leaving the tab
    ref.read(serverDetailNotifierProvider(widget.serverId).notifier).disconnectConsole();
    super.dispose();
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    Haptics.lightTap();
    AppSnackbar.showSuccess(context, 'Address copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final serverAsync = ref.watch(serverDetailProvider(widget.serverId));
    final status = ref.watch(serverStatusProvider(widget.serverId));

    return Column(
      children: [
        // Connection Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              // Connection status dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == 'running' ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // IP:port
              serverAsync.when(
                data: (server) {
                  final address = '${server.allocation.ip}:${server.allocation.port}';
                  return GestureDetector(
                    onTap: () => _copyAddress(address),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          address,
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.copy, size: 14, color: AppColors.textTertiary),
                      ],
                    ),
                  );
                },
                loading: () => const Text(
                  'Connecting...',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: AppColors.textTertiary),
                ),
                error: (_, __) => const Text(
                  'Error',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              const Spacer(),
              // Clear console button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  Haptics.lightTap();
                  ref.read(serverDetailNotifierProvider(widget.serverId).notifier).clearConsole();
                },
                tooltip: 'Clear console',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),

        // Console Output
        Expanded(
          child: ConsoleOutput(serverId: widget.serverId),
        ),

        // Power Buttons
        PowerButtons(serverId: widget.serverId),

        // Command Input
        CommandInput(serverId: widget.serverId),
      ],
    );
  }
}
