enum ConsoleMessageType { output, input, status, error }

class ConsoleMessage {
  final String content;
  final DateTime timestamp;
  final ConsoleMessageType type;

  ConsoleMessage({
    required this.content,
    required this.timestamp,
    required this.type,
  });
}
