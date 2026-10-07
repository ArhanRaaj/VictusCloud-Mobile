import 'package:json_annotation/json_annotation.dart';

part 'subuser_model.g.dart';

@JsonSerializable(createToJson: true)
class SubuserModel {
  final String uuid;
  final String username;
  final String email;
  final String? image;
  final bool twoFactorEnabled;
  final List<String> permissions;

  SubuserModel({
    required this.uuid,
    required this.username,
    required this.email,
    this.image,
    required this.twoFactorEnabled,
    required this.permissions,
  });

  factory SubuserModel.fromJson(Map<String, dynamic> json) => _$SubuserModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubuserModelToJson(this);
}
