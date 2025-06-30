// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  employeeId: (json['employeeId'] as num?)?.toInt(),
  employeeCode: json['employeeCode'] as String,
  store: Store.fromJson(json['store'] as Map<String, dynamic>),
  roles:
      (json['roles'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  email: json['email'] as String,
  password: json['password'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  dateOfBirth:
      json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
  specialization: json['specialization'] as String?,
  baseSalary: BigDecimal.fromJson(json['baseSalary']),
  commissionRate: BigDecimal.fromJson(json['commissionRate']),
  salaryType: $enumDecode(_$SalaryTypeEnumMap, json['salaryType']),
  isActive: json['isActive'] as bool? ?? true,
  averageRating:
      json['averageRating'] == null
          ? const BigDecimal('0.00')
          : BigDecimal.fromJson(json['averageRating']),
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'employeeCode': instance.employeeCode,
  'store': instance.store.toJson(),
  'roles': instance.roles.map((e) => e.toJson()).toList(),
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'email': instance.email,
  'password': instance.password,
  'phoneNumber': instance.phoneNumber,
  'gender': _$GenderEnumMap[instance.gender],
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'specialization': instance.specialization,
  'baseSalary': _bigDecimalToJson(instance.baseSalary),
  'commissionRate': _bigDecimalToJson(instance.commissionRate),
  'salaryType': _$SalaryTypeEnumMap[instance.salaryType]!,
  'isActive': instance.isActive,
  'averageRating': _bigDecimalToJson(instance.averageRating),
  'totalReviews': instance.totalReviews,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$GenderEnumMap = {
  Gender.MALE: 'MALE',
  Gender.FEMALE: 'FEMALE',
  Gender.OTHER: 'OTHER',
};

const _$SalaryTypeEnumMap = {
  SalaryType.FIXED: 'FIXED',
  SalaryType.COMMISSION: 'COMMISSION',
  SalaryType.MIXED: 'MIXED',
};
