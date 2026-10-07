import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/widgets/app_scaffold.dart';
import 'package:victus_app/core/widgets/status_indicator.dart';
import 'package:victus_app/core/widgets/error_state.dart';
import 'package:victus_app/core/widgets/skeleton_loader.dart';
import 'package:victus_app/features/server/presentation/providers/server_detail_provider.dart';
import 'package:victus_app/features/server/presentation/screens/console_tab.dart';
import 'package:victus_app/features/server/presentation/screens/stats_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/files_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/databases_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/schedules_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/backups_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/users_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/network_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/startup_tab.dart';
import 'package:victus_app/features/server/presentation/tabs/settings_tab.dart';

class ServerDetailScreen extends ConsumerStatefulWidget {
  final String serverId;

  const ServerDetailScreen({Key? key, required this.serverId}) : super(key: key);

  @override
  ConsumerState<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends ConsumerState<ServerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serverDetailNotifierProvider).connectConsole(widget.serverId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverAsyncValue = ref.watch(serverDetailProvider(widget.serverId));
    final statusAsyncValue = ref.watch(serverStatusProvider(widget.serverId));
    
    final status = statusAsyncValue.valueOrNull ?? 'offline';

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            serverAsyncValue.when(
              data: (server) => Text(server.name, style: AppTypography.h3),
              loading: () => SkeletonLoader(width: 100, height: 20),
              error: (_, __) => const Text('Error', style: AppTypography.h3),
            ),
            const SizedBox(width: 8),
            StatusIndicator(status: status),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {
              // Overflow menu logic
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.textPrimary,
          indicatorWeight: 1,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.terminal), text: 'Console'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
            Tab(icon: Icon(Icons.folder), text: 'Files'),
            Tab(icon: Icon(Icons.data_usage), text: 'Databases'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedules'),
            Tab(icon: Icon(Icons.backup), text: 'Backups'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.wifi), text: 'Network'),
            Tab(icon: Icon(Icons.rocket_launch), text: 'Startup'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: serverAsyncValue.when(
        data: (server) {
          return TabBarView(
            controller: _tabController,
            children: [
              ConsoleTab(serverId: widget.serverId),
              StatsTab(serverId: widget.serverId),
              FilesTab(serverId: widget.serverId),
              DatabasesTab(serverId: widget.serverId),
              SchedulesTab(serverId: widget.serverId),
              BackupsTab(serverId: widget.serverId),
              UsersTab(serverId: widget.serverId),
              NetworkTab(serverId: widget.serverId),
              StartupTab(serverId: widget.serverId),
              SettingsTab(serverId: widget.serverId),
            ],
          );
        },
        loading: () => const Center(child: SkeletonLoader(width: double.infinity, height: double.infinity)),
        error: (error, stack) => ErrorState(message: error.toString()),
      ),
    );
  }
}
