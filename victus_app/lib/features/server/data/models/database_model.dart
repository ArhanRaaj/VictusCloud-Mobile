import 'package:json_annotation/json_annotation.dart';

part 'database_model.g.dart';

@JsonSerializable(createToJson: true)
class DatabaseModel {
  final String id;
  final String name;
  final String username;
  final String connectionString;
  final String host;
  final int port;
  final int maxConnections;

  DatabaseModel({
    required this.id,
    required this.name,
    required this.username,
    required this.connectionString,
    required this.host,
    required this.port,
    required this.maxConnections,
  });

  factory DatabaseModel.fromJson(Map<String, dynamic> json) => _$DatabaseModelFromJson(json);
  Map<String, dynamic> toJson() => _$DatabaseModelToJson(this);
}
