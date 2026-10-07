import 'package:json_annotation/json_annotation.dart';

part 'ticket_model.g.dart';

@JsonSerializable(createToJson: true)
class TicketModel {
  final int id;
  final String subject;
  final String status;
  final String priority;
  final String department;
  final String? lastReply;
  final List<TicketMessage>? messages;

  TicketModel({
    required this.id,
    required this.subject,
    required this.status,
    required this.priority,
    required this.department,
    this.lastReply,
    this.messages,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => _$TicketModelFromJson(json);
  Map<String, dynamic> toJson() => _$TicketModelToJson(this);
}

@JsonSerializable(createToJson: true)
class TicketMessage {
  final int id;
  final String message;
  final int userId;
  final String createdAt;

  TicketMessage({
    required this.id,
    required this.message,
    required this.userId,
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) => _$TicketMessageFromJson(json);
  Map<String, dynamic> toJson() => _$TicketMessageToJson(this);
}
