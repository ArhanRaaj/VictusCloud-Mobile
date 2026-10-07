import 'package:victus_app/core/network/pterodactyl_client.dart';
import 'package:victus_app/core/errors/app_exception.dart';
import 'package:victus_app/features/server/data/models/ptero_server.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import 'package:victus_app/features/server/data/models/websocket_auth.dart';

class ServerRepository {
  final PterodactylClient _client;

  ServerRepository(this._client);

  Future<PteroServer> getServer(String id) async {
    try {
      return await _client.getServer(id);
    } catch (e) {
      throw ApiException('Failed to load server: $e');
    }
  }

  Future<ServerResources> getResources(String id) async {
    try {
      return await _client.getServerResources(id);
    } catch (e) {
      throw ApiException('Failed to load resources: $e');
    }
  }

  Future<void> sendPowerAction(String id, String action) async {
    try {
      await _client.sendPowerAction(id, action);
    } catch (e) {
      throw ApiException('Failed to send power action: $e');
    }
  }

  Future<void> sendCommand(String id, String command) async {
    try {
      await _client.sendCommand(id, command);
    } catch (e) {
      throw ApiException('Failed to send command: $e');
    }
  }

  Future<WebsocketAuth> getWebsocketCredentials(String id) async {
    try {
      return await _client.getWebsocketCredentials(id);
    } catch (e) {
      throw ApiException('Failed to get websocket credentials: $e');
    }
  }
}
