import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable(createToJson: true)
class ScheduleModel {
  final int id;
  final String name;
  final bool isActive;
  final bool isProcessing;
  final String? lastRunAt;
  final String? nextRunAt;
  final String cronMinute;
  final String cronHour;
  final String cronDayOfMonth;
  final String cronMonth;
  final String cronDayOfWeek;
  final List<ScheduleTask> tasks;

  ScheduleModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isProcessing,
    this.lastRunAt,
    this.nextRunAt,
    required this.cronMinute,
    required this.cronHour,
    required this.cronDayOfMonth,
    required this.cronMonth,
    required this.cronDayOfWeek,
    required this.tasks,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);
}

@JsonSerializable(createToJson: true)
class ScheduleTask {
  final int id;
  final int sequenceId;
  final String action;
  final String payload;
  final int timeOffset;
  final bool isQueued;

  ScheduleTask({
    required this.id,
    required this.sequenceId,
    required this.action,
    required this.payload,
    required this.timeOffset,
    required this.isQueued,
  });

  factory ScheduleTask.fromJson(Map<String, dynamic> json) => _$ScheduleTaskFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleTaskToJson(this);
}
