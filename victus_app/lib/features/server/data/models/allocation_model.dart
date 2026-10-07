import 'package:json_annotation/json_annotation.dart';

part 'allocation_model.g.dart';

@JsonSerializable(createToJson: true)
class AllocationModel {
  final int id;
  final String ip;
  final String? ipAlias;
  final int port;
  final String? notes;
  final bool isDefault;

  AllocationModel({
    required this.id,
    required this.ip,
    this.ipAlias,
    required this.port,
    this.notes,
    required this.isDefault,
  });

  factory AllocationModel.fromJson(Map<String, dynamic> json) => _$AllocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$AllocationModelToJson(this);
}
