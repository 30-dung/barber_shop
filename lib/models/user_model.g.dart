// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userId: (json['userId'] as num?)?.toInt(),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  password: json['password'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  membershipType: json['membershipType'] as String,
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userId': instance.userId,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'password': instance.password,
  'role': _$UserRoleEnumMap[instance.role]!,
  'membershipType': instance.membershipType,
  'loyaltyPoints': instance.loyaltyPoints,
  'createdAt': instance.createdAt,
};

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.employee: 'employee',
  UserRole.admin: 'admin',
};
