import 'package:json_annotation/json_annotation.dart';

part 'ptero_server.g.dart';

@JsonSerializable(createToJson: true)
class PteroServer {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final String node;
  final bool isOwner;
  final ServerLimits limits;
  final ServerFeatureLimits featureLimits;
  final String? status;
  final ServerAllocation allocation;

  PteroServer({
    required this.id,
    required this.uuid,
    required this.name,
    required this.description,
    required this.node,
    required this.isOwner,
    required this.limits,
    required this.featureLimits,
    this.status,
    required this.allocation,
  });

  String get identifier => id;

  factory PteroServer.fromJson(Map<String, dynamic> json) => _$PteroServerFromJson(json);
  Map<String, dynamic> toJson() => _$PteroServerToJson(this);
}

@JsonSerializable(createToJson: true)
class ServerLimits {
  final int memory;
  final int disk;
  final int cpu;
  final int io;
  final int swap;

  ServerLimits({
    required this.memory,
    required this.disk,
    required this.cpu,
    required this.io,
    required this.swap,
  });

  factory ServerLimits.fromJson(Map<String, dynamic> json) => _$ServerLimitsFromJson(json);
  Map<String, dynamic> toJson() => _$ServerLimitsToJson(this);
}

@JsonSerializable(createToJson: true)
class ServerFeatureLimits {
  final int databases;
  final int allocations;
  final int backups;

  ServerFeatureLimits({
    required this.databases,
    required this.allocations,
    required this.backups,
  });

  factory ServerFeatureLimits.fromJson(Map<String, dynamic> json) => _$ServerFeatureLimitsFromJson(json);
  Map<String, dynamic> toJson() => _$ServerFeatureLimitsToJson(this);
}

@JsonSerializable(createToJson: true)
class ServerAllocation {
  final String ip;
  final int port;
  final String? alias;

  ServerAllocation({
    required this.ip,
    required this.port,
    this.alias,
  });

  factory ServerAllocation.fromJson(Map<String, dynamic> json) => _$ServerAllocationFromJson(json);
  Map<String, dynamic> toJson() => _$ServerAllocationToJson(this);
}
