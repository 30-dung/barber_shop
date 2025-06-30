// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_time_registration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkTimeRegistrationRequest _$WorkTimeRegistrationRequestFromJson(
  Map<String, dynamic> json,
) => WorkTimeRegistrationRequest(
  employeeId: (json['employeeId'] as num).toInt(),
  storeId: (json['storeId'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
);

Map<String, dynamic> _$WorkTimeRegistrationRequestToJson(
  WorkTimeRegistrationRequest instance,
) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'storeId': instance.storeId,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
};
