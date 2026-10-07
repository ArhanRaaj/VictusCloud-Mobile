import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:victus_app/features/server/data/models/console_message.dart';
import 'package:victus_app/features/server/data/models/server_resources.dart';
import 'package:victus_app/features/server/data/models/websocket_auth.dart';
import 'package:victus_app/features/server/data/repositories/server_repository.dart';

class ConsoleService {
  final ServerRepository _repository;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _serverId;
  WebsocketAuth? _auth;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;

  final _messagesController = StreamController<ConsoleMessage>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _statsController = StreamController<ServerResources>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  ConsoleService(this._repository);

  Stream<ConsoleMessage> get messageStream => _messagesController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<ServerResources> get statsStream => _statsController.stream;
  Stream<bool> get isConnectedStream => _connectionController.stream;

  bool get isConnected => _channel != null;

  Future<void> connect(String serverId) async {
    _serverId = serverId;
    try {
      _auth = await _repository.getWebsocketCredentials(serverId);
      _connectWebSocket();
    } catch (e) {
      _messagesController.add(ConsoleMessage(
        content: 'Failed to get websocket credentials: $e',
        timestamp: DateTime.now(),
        type: ConsoleMessageType.error,
      ));
    }
  }

  void _connectWebSocket() {
    if (_auth == null) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_auth!.socket));
      _connectionController.add(true);
      _reconnectAttempts = 0;

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      sendAuthPayload();
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final event = data['event'] as String;
      final args = data['args'] as List?;

      switch (event) {
        case 'auth success':
          _messagesController.add(ConsoleMessage(
            content: 'Connected to console.',
            timestamp: DateTime.now(),
            type: ConsoleMessageType.status,
          ));
          break;
        case 'console output':
          if (args != null && args.isNotEmpty) {
            _messagesController.add(ConsoleMessage(
              content: args[0].toString(),
              timestamp: DateTime.now(),
              type: ConsoleMessageType.output,
            ));
          }
          break;
        case 'status':
          if (args != null && args.isNotEmpty) {
            _statusController.add(args[0].toString());
          }
          break;
        case 'stats':
          if (args != null && args.isNotEmpty) {
            final statsJson = jsonDecode(args[0].toString());
            _statsController.add(ServerResources.fromJson(statsJson));
          }
          break;
        case 'token expiring':
          _reauthenticate();
          break;
        case 'token expired':
          _reconnect();
          break;
      }
    } catch (e) {
      // Ignored parsing errors
    }
  }

  void _handleError(error) {
    _messagesController.add(ConsoleMessage(
      content: 'WebSocket Error: $error',
      timestamp: DateTime.now(),
      type: ConsoleMessageType.error,
    ));
    _connectionController.add(false);
    _reconnect();
  }

  void _handleDone() {
    _connectionController.add(false);
    _channel = null;
    if (!_isReconnecting) {
      _messagesController.add(ConsoleMessage(
        content: 'Connection closed.',
        timestamp: DateTime.now(),
        type: ConsoleMessageType.status,
      ));
      _reconnect();
    }
  }

  Future<void> _reauthenticate() async {
    if (_serverId == null) return;
    try {
      _auth = await _repository.getWebsocketCredentials(_serverId!);
      sendAuthPayload();
    } catch (e) {
      // Handle fail
    }
  }

  void _reconnect() {
    if (_isReconnecting || _serverId == null || _reconnectAttempts > 5) return;
    _isReconnecting = true;
    _reconnectAttempts++;
    
    _messagesController.add(ConsoleMessage(
      content: 'Reconnecting (Attempt $_reconnectAttempts)...',
      timestamp: DateTime.now(),
      type: ConsoleMessageType.status,
    ));

    Future.delayed(Duration(seconds: _reconnectAttempts * 2), () async {
      _isReconnecting = false;
      await connect(_serverId!);
    });
  }

  void sendCommand(String command) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'event': 'send command',
        'args': [command]
      }));
      _messagesController.add(ConsoleMessage(
        content: '> $command',
        timestamp: DateTime.now(),
        type: ConsoleMessageType.input,
      ));
    } else {
      _repository.sendCommand(_serverId!, command).catchError((e) {
        _messagesController.add(ConsoleMessage(
          content: 'Failed to send command: $e',
          timestamp: DateTime.now(),
          type: ConsoleMessageType.error,
        ));
      });
      _messagesController.add(ConsoleMessage(
        content: '> $command',
        timestamp: DateTime.now(),
        type: ConsoleMessageType.input,
      ));
    }
  }

  void sendAuthPayload() {
    if (_channel != null && _auth != null) {
      _channel!.sink.add(jsonEncode({
        'event': 'auth',
        'args': [_auth!.token]
      }));
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _serverId = null;
    _auth = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messagesController.close();
    _statusController.close();
    _statsController.close();
    _connectionController.close();
  }
}
