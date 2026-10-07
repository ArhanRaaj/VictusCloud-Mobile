import 'package:json_annotation/json_annotation.dart';

part 'backup_model.g.dart';

@JsonSerializable(createToJson: true)
class BackupModel {
  final String uuid;
  final String name;
  final List<String> ignoredFiles;
  final String? sha256Hash;
  final int bytes;
  final String createdAt;
  final String? completedAt;
  final bool isSuccessful;
  final bool isLocked;

  BackupModel({
    required this.uuid,
    required this.name,
    required this.ignoredFiles,
    this.sha256Hash,
    required this.bytes,
    required this.createdAt,
    this.completedAt,
    required this.isSuccessful,
    required this.isLocked,
  });

  factory BackupModel.fromJson(Map<String, dynamic> json) => _$BackupModelFromJson(json);
  Map<String, dynamic> toJson() => _$BackupModelToJson(this);
}
