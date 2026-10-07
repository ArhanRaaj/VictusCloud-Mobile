import 'package:victus_app/features/server/data/models/ptero_server.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import '../../data/models/billing_summary.dart';

sealed class DashboardState {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<PteroServer> servers;
  final Map<String, ServerResources> resourcesMap;
  final BillingSummary billingSummary;
  final bool isOffline;

  const DashboardLoaded({
    required this.servers,
    required this.resourcesMap,
    required this.billingSummary,
    this.isOffline = false,
  });
}

class DashboardError extends DashboardState {
  final String message;
  final List<PteroServer>? cachedServers;

  const DashboardError({
    required this.message,
    this.cachedServers,
  });
}

class DashboardRefreshing extends DashboardState {
  final List<PteroServer> servers;
  final Map<String, ServerResources> resourcesMap;
  final BillingSummary billingSummary;

  const DashboardRefreshing({
    required this.servers,
    required this.resourcesMap,
    required this.billingSummary,
  });
}
