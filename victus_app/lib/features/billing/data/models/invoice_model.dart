import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable(createToJson: true)
class InvoiceModel {
  final int id;
  final String status;
  final double total;
  final String? dueDate;
  final String? paidDate;
  final List<InvoiceItem> items;

  InvoiceModel({
    required this.id,
    required this.status,
    required this.total,
    this.dueDate,
    this.paidDate,
    required this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);
}

@JsonSerializable(createToJson: true)
class InvoiceItem {
  final int id;
  final String description;
  final double total;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);
}
