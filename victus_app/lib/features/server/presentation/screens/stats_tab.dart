import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/features/server/presentation/providers/server_detail_provider.dart';
import 'package:victus_app/features/server/presentation/widgets/stat_card.dart';

class StatsTab extends ConsumerWidget {
  final String serverId;

  const StatsTab({Key? key, required this.serverId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(serverResourcesProvider(serverId));

    return resourcesAsync.when(
      data: (resources) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StatCard(
              title: 'CPU Usage',
              currentValue: '\${resources.cpuAbsolute.toStringAsFixed(1)}%',
              detailText: 'Max: \${resources.cpuLimit > 0 ? resources.cpuLimit : "Unlimited"}%',
              hasChart: true,
            ),
            const SizedBox(height: 16),
            StatCard(
              title: 'Memory Usage',
              currentValue: '\${(resources.memoryBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
              detailText: '/ \${(resources.memoryLimitBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
              hasProgressBar: true,
              progress: resources.memoryLimitBytes > 0 ? resources.memoryBytes / resources.memoryLimitBytes : 0,
            ),
            const SizedBox(height: 16),
            StatCard(
              title: 'Disk Usage',
              currentValue: '\${(resources.diskBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
              detailText: '/ \${(resources.diskLimitBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
              hasProgressBar: true,
              progress: resources.diskLimitBytes > 0 ? resources.diskBytes / resources.diskLimitBytes : 0,
            ),
            const SizedBox(height: 16),
            StatCard(
              title: 'Network',
              currentValue: 'Rx: \${(resources.networkRxBytes / 1024).toStringAsFixed(1)} KB/s\nTx: \${(resources.networkTxBytes / 1024).toStringAsFixed(1)} KB/s',
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
      error: (e, _) => Center(child: Text('Error loading stats: $e', style: const TextStyle(color: AppColors.textPrimary))),
    );
  }
}
