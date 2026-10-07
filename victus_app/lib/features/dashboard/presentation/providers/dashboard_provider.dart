import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/network/pterodactyl_client.dart';
import 'package:victus_app/core/network/paymenter_client.dart';
import 'package:victus_app/core/cache/cache_service.dart';
import 'package:victus_app/features/server/data/models/ptero_server.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import '../../data/models/billing_summary.dart';
import '../../data/models/power_action.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_state.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  // Assuming these are provided elsewhere in the real app, mocking here for completeness
  return DashboardRepository(
    PterodactylClient(),
    PaymenterClient(),
    CacheService(),
  );
});

final dashboardStateProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});

final serverResourcesProvider = FutureProvider.family<ServerResources, String>((ref, serverId) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchServerResources(serverId);
});

final billingSummaryProvider = FutureProvider<BillingSummary>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchBillingSummary();
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  Timer? _refreshTimer;

  DashboardNotifier(this._repository) : super(const DashboardLoading()) {
    loadDashboard();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state is DashboardLoaded) {
        _refreshResourcesOnly();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDashboard() async {
    state = const DashboardLoading();
    try {
      final servers = await _repository.fetchServers();
      final resourcesMap = await _repository.fetchAllServerResources(servers);
      final billingSummary = await _repository.fetchBillingSummary();

      state = DashboardLoaded(
        servers: servers,
        resourcesMap: resourcesMap,
        billingSummary: billingSummary,
      );
    } catch (e) {
      state = DashboardError(message: 'Failed to load dashboard: $e');
    }
  }

  Future<void> refreshDashboard() async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      state = DashboardRefreshing(
        servers: currentState.servers,
        resourcesMap: currentState.resourcesMap,
        billingSummary: currentState.billingSummary,
      );
    }

    try {
      final servers = await _repository.fetchServers();
      final resourcesMap = await _repository.fetchAllServerResources(servers);
      final billingSummary = await _repository.fetchBillingSummary();

      state = DashboardLoaded(
        servers: servers,
        resourcesMap: resourcesMap,
        billingSummary: billingSummary,
      );
    } catch (e) {
      if (state is DashboardRefreshing) {
        final prevState = state as DashboardRefreshing;
        state = DashboardLoaded(
          servers: prevState.servers,
          resourcesMap: prevState.resourcesMap,
          billingSummary: prevState.billingSummary,
          isOffline: true,
        );
      } else {
        state = DashboardError(message: 'Failed to refresh dashboard: $e');
      }
    }
  }

  Future<void> _refreshResourcesOnly() async {
    if (state is! DashboardLoaded) return;
    final currentState = state as DashboardLoaded;

    try {
      final resourcesMap = await _repository.fetchAllServerResources(currentState.servers);
      state = DashboardLoaded(
        servers: currentState.servers,
        resourcesMap: resourcesMap,
        billingSummary: currentState.billingSummary,
        isOffline: currentState.isOffline,
      );
    } catch (e) {
      // Silent fail for auto-refresh
    }
  }

  Future<void> sendPowerAction(String serverId, PowerAction action) async {
    if (state is! DashboardLoaded) return;
    final currentState = state as DashboardLoaded;

    try {
      // Optimistic update logic could go here
      await _repository.sendPowerAction(serverId, action);
      // Wait a moment then refresh resources to get new status
      await Future.delayed(const Duration(seconds: 2));
      final resources = await _repository.fetchServerResources(serverId);
      
      final updatedMap = Map<String, ServerResources>.from(currentState.resourcesMap);
      updatedMap[serverId] = resources;
      
      state = DashboardLoaded(
        servers: currentState.servers,
        resourcesMap: updatedMap,
        billingSummary: currentState.billingSummary,
        isOffline: currentState.isOffline,
      );
    } catch (e) {
      // Revert or show error
    }
  }
}
