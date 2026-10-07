import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/features/server/data/repositories/server_repository.dart';
import 'package:victus_app/features/server/data/services/console_service.dart';
import 'package:victus_app/data/models/ptero_server.dart';
import 'package:victus_app/data/models/server_resources.dart';
import 'package:victus_app/features/server/data/models/console_message.dart';
import 'package:victus_app/core/network/pterodactyl_client.dart';

final pterodactylClientProvider = Provider<PterodactylClient>((ref) {
  return PterodactylClient();
});

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  return ServerRepository(ref.watch(pterodactylClientProvider));
});

final consoleServiceProvider = Provider.family<ConsoleService, String>((ref, serverId) {
  final service = ConsoleService(ref.watch(serverRepositoryProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

final serverDetailProvider = FutureProvider.family<PteroServer, String>((ref, serverId) {
  return ref.watch(serverRepositoryProvider).getServer(serverId);
});

final serverResourcesProvider = StreamProvider.family<ServerResources, String>((ref, serverId) {
  return ref.watch(consoleServiceProvider(serverId)).statsStream;
});

final consoleMessagesProvider = StreamProvider.family<List<ConsoleMessage>, String>((ref, serverId) async* {
  final service = ref.watch(consoleServiceProvider(serverId));
  final messages = <ConsoleMessage>[];
  
  await for (final message in service.messageStream) {
    messages.add(message);
    if (messages.length > 500) {
      messages.removeAt(0);
    }
    yield List.unmodifiable(messages);
  }
});

final serverStatusProvider = StreamProvider.family<String, String>((ref, serverId) {
  return ref.watch(consoleServiceProvider(serverId)).statusStream;
});

final commandHistoryProvider = StateProvider.family<List<String>, String>((ref, serverId) => []);

class ServerDetailNotifier {
  final Ref _ref;

  ServerDetailNotifier(this._ref);

  void connectConsole(String serverId) {
    _ref.read(consoleServiceProvider(serverId)).connect(serverId);
  }

  void disconnectConsole(String serverId) {
    _ref.read(consoleServiceProvider(serverId)).disconnect();
  }

  void sendCommand(String serverId, String command) {
    _ref.read(consoleServiceProvider(serverId)).sendCommand(command);
    final history = _ref.read(commandHistoryProvider(serverId));
    _ref.read(commandHistoryProvider(serverId).notifier).state = [...history, command];
  }

  Future<void> sendPowerAction(String serverId, String action) async {
    await _ref.read(serverRepositoryProvider).sendPowerAction(serverId, action);
  }
}

final serverDetailNotifierProvider = Provider((ref) => ServerDetailNotifier(ref));
