import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable(createToJson: true)
class ServiceModel {
  final int id;
  final String name;
  final String status;
  final String? dueDate;
  final double price;
  final String billingCycle;

  ServiceModel({
    required this.id,
    required this.name,
    required this.status,
    this.dueDate,
    required this.price,
    required this.billingCycle,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}
