import 'package:victus_app/core/network/pterodactyl_client.dart';
import 'package:victus_app/core/error/app_exception.dart';
import 'package:victus_app/data/models/ptero_server.dart';
import 'package:victus_app/data/models/server_resources.dart';
import 'package:victus_app/data/models/websocket_auth.dart';

class ServerRepository {
  final PterodactylClient _client;

  ServerRepository(this._client);

  Future<PteroServer> getServer(String id) async {
    try {
      final response = await _client.get('/api/client/servers/$id');
      return PteroServer.fromJson(response.data['attributes']);
    } catch (e) {
      throw AppException('Failed to load server: $e');
    }
  }

  Future<ServerResources> getResources(String id) async {
    try {
      final response = await _client.get('/api/client/servers/$id/resources');
      return ServerResources.fromJson(response.data['attributes']);
    } catch (e) {
      throw AppException('Failed to load resources: $e');
    }
  }

  Future<void> sendPowerAction(String id, String action) async {
    try {
      await _client.post(
        '/api/client/servers/$id/power',
        data: {'signal': action},
      );
    } catch (e) {
      throw AppException('Failed to send power action: $e');
    }
  }

  Future<void> sendCommand(String id, String command) async {
    try {
      await _client.post(
        '/api/client/servers/$id/command',
        data: {'command': command},
      );
    } catch (e) {
      throw AppException('Failed to send command: $e');
    }
  }

  Future<WebsocketAuth> getWebsocketCredentials(String id) async {
    try {
      final response = await _client.get('/api/client/servers/$id/websocket');
      return WebsocketAuth.fromJson(response.data['data']);
    } catch (e) {
      throw AppException('Failed to get websocket credentials: $e');
    }
  }
}
