// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceDetail _$ServiceDetailFromJson(Map<String, dynamic> json) =>
    ServiceDetail(
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      serviceImg: json['serviceImg'] as String?,
    );

Map<String, dynamic> _$ServiceDetailToJson(ServiceDetail instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'serviceImg': instance.serviceImg,
    };
