import 'package:dio/dio.dart';
import 'package:victus_app/features/server/data/models/ptero_server.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import 'package:victus_app/features/server/data/models/file_object.dart';
import 'package:victus_app/features/server/data/models/database_model.dart';
import 'package:victus_app/features/server/data/models/schedule_model.dart';
import 'package:victus_app/features/server/data/models/subuser_model.dart';
import 'package:victus_app/features/server/data/models/backup_model.dart';
import 'package:victus_app/features/server/data/models/allocation_model.dart';

class WebsocketAuth {
  final String token;
  final String socketUrl;

  WebsocketAuth({required this.token, required this.socketUrl});
}

class PterodactylClient {
  final Dio apiClient;
  final String baseUrl;

  PterodactylClient({required this.apiClient, required this.baseUrl});

  Future<List<PteroServer>> listServers({int page = 1}) async {
    final response = await apiClient.get('$baseUrl/servers', queryParameters: {'page': page});
    return (response.data['data'] as List).map((e) => PteroServer.fromJson(e['attributes'])).toList();
  }

  Future<PteroServer> getServer(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId');
    return PteroServer.fromJson(response.data['attributes']);
  }

  Future<ServerResources> getServerResources(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/resources');
    return ServerResources.fromJson(response.data['attributes']);
  }

  Future<void> sendPowerAction(String serverId, String powerAction) async {
    await apiClient.post('$baseUrl/servers/$serverId/power', data: {'signal': powerAction});
  }

  Future<void> sendCommand(String serverId, String command) async {
    await apiClient.post('$baseUrl/servers/$serverId/command', data: {'command': command});
  }

  Future<WebsocketAuth> getWebsocketCredentials(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/websocket');
    final data = response.data['data'];
    return WebsocketAuth(token: data['token'], socketUrl: data['socket']);
  }

  Future<List<FileObject>> listFiles(String serverId, String directory) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/files/list', queryParameters: {'directory': directory});
    return (response.data['data'] as List).map((e) => FileObject.fromJson(e['attributes'])).toList();
  }

  Future<String> getFileContent(String serverId, String filePath) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/files/contents', queryParameters: {'file': filePath});
    return response.data.toString();
  }

  Future<void> writeFile(String serverId, String filePath, String content) async {
    await apiClient.post('$baseUrl/servers/$serverId/files/write', queryParameters: {'file': filePath}, data: content);
  }

  Future<void> renameFile(String serverId, String root, List<Map<String, String>> files) async {
    await apiClient.put('$baseUrl/servers/$serverId/files/rename', data: {'root': root, 'files': files});
  }

  Future<void> deleteFile(String serverId, String root, List<String> files) async {
    await apiClient.post('$baseUrl/servers/$serverId/files/delete', data: {'root': root, 'files': files});
  }

  Future<void> compressFiles(String serverId, String root, List<String> files) async {
    await apiClient.post('$baseUrl/servers/$serverId/files/compress', data: {'root': root, 'files': files});
  }

  Future<void> decompressFile(String serverId, String root, String file) async {
    await apiClient.post('$baseUrl/servers/$serverId/files/decompress', data: {'root': root, 'file': file});
  }

  Future<void> createFolder(String serverId, String root, String name) async {
    await apiClient.post('$baseUrl/servers/$serverId/files/create-folder', data: {'root': root, 'name': name});
  }

  Future<String> uploadFile(String serverId, String directory, String filePath) async {
    // Need to handle actual upload logically if multi-part. This gets URL mostly.
    final response = await apiClient.get('$baseUrl/servers/$serverId/files/upload');
    final uploadUrl = response.data['attributes']['url'];
    // Would require using uploadUrl to POST multipart/form-data. Stubbed representation.
    return uploadUrl;
  }

  Future<String> downloadFile(String serverId, String filePath) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/files/download', queryParameters: {'file': filePath});
    return response.data['attributes']['url'];
  }

  Future<List<DatabaseModel>> listDatabases(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/databases');
    return (response.data['data'] as List).map((e) => DatabaseModel.fromJson(e['attributes'])).toList();
  }

  Future<DatabaseModel> createDatabase(String serverId, String database, String remote) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/databases', data: {'database': database, 'remote': remote});
    return DatabaseModel.fromJson(response.data['attributes']);
  }

  Future<void> deleteDatabase(String serverId, String id) async {
    await apiClient.delete('$baseUrl/servers/$serverId/databases/$id');
  }

  Future<void> rotateDatabasePassword(String serverId, String id) async {
    await apiClient.post('$baseUrl/servers/$serverId/databases/$id/rotate-password');
  }

  Future<List<ScheduleModel>> listSchedules(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/schedules');
    return (response.data['data'] as List).map((e) => ScheduleModel.fromJson(e['attributes'])).toList();
  }

  Future<ScheduleModel> createSchedule(String serverId, Map<String, dynamic> data) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/schedules', data: data);
    return ScheduleModel.fromJson(response.data['attributes']);
  }

  Future<ScheduleModel> updateSchedule(String serverId, int id, Map<String, dynamic> data) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/schedules/$id', data: data);
    return ScheduleModel.fromJson(response.data['attributes']);
  }

  Future<void> deleteSchedule(String serverId, int id) async {
    await apiClient.delete('$baseUrl/servers/$serverId/schedules/$id');
  }

  Future<void> executeSchedule(String serverId, int id) async {
    await apiClient.post('$baseUrl/servers/$serverId/schedules/$id/execute');
  }

  Future<List<SubuserModel>> listSubusers(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/users');
    return (response.data['data'] as List).map((e) => SubuserModel.fromJson(e['attributes'])).toList();
  }

  Future<SubuserModel> createSubuser(String serverId, String email, List<String> permissions) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/users', data: {'email': email, 'permissions': permissions});
    return SubuserModel.fromJson(response.data['attributes']);
  }

  Future<SubuserModel> updateSubuser(String serverId, String uuid, List<String> permissions) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/users/$uuid', data: {'permissions': permissions});
    return SubuserModel.fromJson(response.data['attributes']);
  }

  Future<void> deleteSubuser(String serverId, String uuid) async {
    await apiClient.delete('$baseUrl/servers/$serverId/users/$uuid');
  }

  Future<List<BackupModel>> listBackups(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/backups');
    return (response.data['data'] as List).map((e) => BackupModel.fromJson(e['attributes'])).toList();
  }

  Future<BackupModel> createBackup(String serverId, {String? name, List<String>? ignored, bool? isLocked}) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/backups', data: {
      'name': name,
      'ignored': ignored?.join('\n'),
      'is_locked': isLocked,
    });
    return BackupModel.fromJson(response.data['attributes']);
  }

  Future<String> downloadBackup(String serverId, String uuid) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/backups/$uuid/download');
    return response.data['attributes']['url'];
  }

  Future<void> restoreBackup(String serverId, String uuid) async {
    await apiClient.post('$baseUrl/servers/$serverId/backups/$uuid/restore');
  }

  Future<void> deleteBackup(String serverId, String uuid) async {
    await apiClient.delete('$baseUrl/servers/$serverId/backups/$uuid');
  }

  Future<void> lockBackup(String serverId, String uuid) async {
    await apiClient.post('$baseUrl/servers/$serverId/backups/$uuid/lock');
  }

  Future<List<AllocationModel>> listAllocations(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/network/allocations');
    return (response.data['data'] as List).map((e) => AllocationModel.fromJson(e['attributes'])).toList();
  }

  Future<AllocationModel> setAllocationAsPrimary(String serverId, int id) async {
    final response = await apiClient.post('$baseUrl/servers/$serverId/network/allocations/$id/primary');
    return AllocationModel.fromJson(response.data['attributes']);
  }

  Future<Map<String, dynamic>> getStartup(String serverId) async {
    final response = await apiClient.get('$baseUrl/servers/$serverId/startup');
    return response.data['meta']['startup_command'] ?? {}; // Simplified representation
  }

  Future<void> updateStartupVariable(String serverId, String key, String value) async {
    await apiClient.put('$baseUrl/servers/$serverId/startup/variable', data: {'key': key, 'value': value});
  }

  Future<void> renameServer(String serverId, String name) async {
    await apiClient.post('$baseUrl/servers/$serverId/settings/rename', data: {'name': name});
  }

  Future<void> reinstallServer(String serverId) async {
    await apiClient.post('$baseUrl/servers/$serverId/settings/reinstall');
  }

  Future<Map<String, dynamic>> getServerSftpDetails(String serverId) async {
    // SFTP details are usually part of the server object or a separate settings endpoint
    final response = await apiClient.get('$baseUrl/servers/$serverId');
    return response.data['attributes']['sftp_details'];
  }
}
