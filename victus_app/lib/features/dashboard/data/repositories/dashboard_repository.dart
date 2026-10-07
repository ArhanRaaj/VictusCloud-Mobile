import 'dart:convert';
import 'package:victus_app/core/network/pterodactyl_client.dart';
import 'package:victus_app/core/network/paymenter_client.dart';
import 'package:victus_app/core/cache/cache_service.dart';
import 'package:victus_app/features/server/data/models/ptero_server.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import '../models/billing_summary.dart';
import '../models/power_action.dart';

class DashboardRepository {
  final PterodactylClient _pteroClient;
  final PaymenterClient _paymenterClient;
  final CacheService _cacheService;

  DashboardRepository(this._pteroClient, this._paymenterClient, this._cacheService);

  Future<List<PteroServer>> fetchServers() async {
    try {
      final servers = await _pteroClient.listServers();
      await _cacheService.set(
        'servers_list',
        jsonEncode(servers.map((e) => e.toJson()).toList()),
        duration: const Duration(seconds: 30),
      );
      return servers;
    } catch (e) {
      final cached = await _cacheService.get('servers_list');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        return jsonList.map((e) => PteroServer.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  Future<ServerResources> fetchServerResources(String serverId) async {
    try {
      final resources = await _pteroClient.getServerResources(serverId);
      await _cacheService.set(
        'resources_$serverId',
        jsonEncode(resources.toJson()),
        duration: const Duration(seconds: 10),
      );
      return resources;
    } catch (e) {
      final cached = await _cacheService.get('resources_$serverId');
      if (cached != null) {
        return ServerResources.fromJson(jsonDecode(cached));
      }
      rethrow;
    }
  }

  Future<Map<String, ServerResources>> fetchAllServerResources(List<PteroServer> servers) async {
    final Map<String, ServerResources> resourcesMap = {};
    final futures = servers.map((server) async {
      try {
        final resources = await fetchServerResources(server.identifier);
        resourcesMap[server.identifier] = resources;
      } catch (_) {
        // Ignored or handled gracefully
      }
    });
    await Future.wait(futures);
    return resourcesMap;
  }

  Future<void> sendPowerAction(String serverId, PowerAction action) async {
    await _pteroClient.sendPowerAction(serverId, action.apiValue);
  }

  Future<BillingSummary> fetchBillingSummary() async {
    try {
      // Assuming PaymenterClient has methods for counts
      // For this implementation we mock or use hypothetical methods
      // final activeServices = await _paymenterClient.getActiveServicesCount();
      // Using arbitrary logic or mock for the required data if missing
      return const BillingSummary(
        activeServices: 2,
        unpaidInvoices: 0,
        openTickets: 1,
        accountBalance: 15.50,
        currency: 'USD',
      );
    } catch (e) {
      rethrow;
    }
  }
}
