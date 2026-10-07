import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class NetworkTab extends ConsumerWidget {
  final String serverId;

  const NetworkTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real implementation, fetch allocations from provider
    final dummyAllocations = [
      {'ip': '192.168.1.100', 'port': '25565', 'alias': 'node.victuscloud.com', 'isPrimary': true, 'notes': 'Main Game Port'},
      {'ip': '192.168.1.100', 'port': '8080', 'alias': 'node.victuscloud.com', 'isPrimary': false, 'notes': 'Web Map'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: dummyAllocations.length,
      itemBuilder: (context, index) {
        final alloc = dummyAllocations[index];
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
                      Text('${alloc['ip']}:${alloc['port']}', style: AppTypography.h4),
                      if (alloc['isPrimary'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Primary', style: AppTypography.bodySmall),
                        )
                      else
                        TextButton(
                          onPressed: () {},
                          child: const Text('Make Primary', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Alias: ${alloc['alias']}', style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Notes: ${alloc['notes']}', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
