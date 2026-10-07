import 'package:json_annotation/json_annotation.dart';

part 'server_resources.g.dart';

@JsonSerializable(createToJson: true)
class ServerResources {
  final String currentState;
  final int memoryBytes;
  final double cpuAbsolute;
  final int diskBytes;
  final int networkRxBytes;
  final int networkTxBytes;
  final int uptime;
  final bool isSuspended;

  ServerResources({
    required this.currentState,
    required this.memoryBytes,
    required this.cpuAbsolute,
    required this.diskBytes,
    required this.networkRxBytes,
    required this.networkTxBytes,
    required this.uptime,
    required this.isSuspended,
  });

  factory ServerResources.fromJson(Map<String, dynamic> json) => _$ServerResourcesFromJson(json);
  Map<String, dynamic> toJson() => _$ServerResourcesToJson(this);
}
