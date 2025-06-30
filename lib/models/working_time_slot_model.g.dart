// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_time_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingTimeSlot _$WorkingTimeSlotFromJson(Map<String, dynamic> json) =>
    WorkingTimeSlot(
      timeSlotId: (json['timeSlotId'] as num?)?.toInt(),
      employee:
          json['employee'] == null
              ? null
              : Employee.fromJson(json['employee'] as Map<String, dynamic>),
      store:
          json['store'] == null
              ? null
              : Store.fromJson(json['store'] as Map<String, dynamic>),
      startTime:
          json['startTime'] == null
              ? null
              : DateTime.parse(json['startTime'] as String),
      endTime:
          json['endTime'] == null
              ? null
              : DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool?,
    );

Map<String, dynamic> _$WorkingTimeSlotToJson(WorkingTimeSlot instance) =>
    <String, dynamic>{
      'timeSlotId': instance.timeSlotId,
      'employee': instance.employee?.toJson(),
      'store': instance.store?.toJson(),
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isAvailable': instance.isAvailable,
    };
