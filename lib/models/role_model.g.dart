// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  roleId: (json['roleId'] as num?)?.toInt(),
  roleName: json['roleName'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'roleId': instance.roleId,
  'roleName': instance.roleName,
  'description': instance.description,
};
