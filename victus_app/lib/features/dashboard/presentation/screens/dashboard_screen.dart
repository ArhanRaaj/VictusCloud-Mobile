import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';
import 'package:victus_app/core/widgets/app_scaffold.dart';
import 'package:victus_app/core/widgets/pull_to_refresh.dart';
import 'package:victus_app/core/widgets/skeleton_loader.dart';
import 'package:victus_app/core/widgets/empty_state.dart';
import 'package:victus_app/core/widgets/error_state.dart';
import 'package:victus_app/core/widgets/app_button.dart';
import '../providers/dashboard_provider.dart';
import '../../domain/entities/dashboard_state.dart';
import '../widgets/greeting_header.dart';
import '../widgets/summary_strip.dart';
import '../widgets/server_card.dart';
import '../widgets/offline_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStateProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'VictusCloud',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppColors.iconPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: PullToRefresh(
        onRefresh: () => ref.read(dashboardStateProvider.notifier).refreshDashboard(),
        child: _buildBody(context, state, ref),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state, WidgetRef ref) {
    if (state is DashboardLoading) {
      return const _SkeletonDashboard();
    } else if (state is DashboardError) {
      return ErrorState(
        message: state.message,
        onRetry: () => ref.read(dashboardStateProvider.notifier).loadDashboard(),
      );
    }

    final servers = state is DashboardLoaded 
        ? state.servers 
        : (state as DashboardRefreshing).servers;
    
    final resourcesMap = state is DashboardLoaded 
        ? state.resourcesMap 
        : (state as DashboardRefreshing).resourcesMap;
    
    final billingSummary = state is DashboardLoaded 
        ? state.billingSummary 
        : (state as DashboardRefreshing).billingSummary;
        
    final isOffline = state is DashboardLoaded ? state.isOffline : false;

    return CustomScrollView(
      slivers: [
        if (isOffline)
          const SliverToBoxAdapter(child: OfflineBanner()),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              GreetingHeader(name: 'User'), // Could get from auth provider
              const SizedBox(height: AppSpacing.xl),
              SummaryStrip(summary: billingSummary),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Your Servers',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              if (servers.isEmpty)
                EmptyState(
                  message: 'No servers yet',
                  action: AppButton(
                    text: 'Order a server',
                    onPressed: () {},
                  ),
                )
              else
                ...servers.map((server) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ServerCard(
                      server: server,
                      resources: resourcesMap[server.identifier],
                    ),
                  );
                }).toList(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SkeletonDashboard extends StatelessWidget {
  const _SkeletonDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SkeletonLoader(height: 32, width: 200),
        const SizedBox(height: AppSpacing.xs),
        SkeletonLoader(height: 16, width: 120),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: List.generate(4, (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: SkeletonLoader(height: 60),
            ),
          )),
        ),
        const SizedBox(height: AppSpacing.xl),
        SkeletonLoader(height: 24, width: 120),
        const SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 200),
        const SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 200),
      ],
    );
  }
}
