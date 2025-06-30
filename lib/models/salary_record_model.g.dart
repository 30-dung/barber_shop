// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalaryRecord _$SalaryRecordFromJson(Map<String, dynamic> json) => SalaryRecord(
  salaryRecordId: (json['salaryRecordId'] as num?)?.toInt(),
  employee: Employee.fromJson(json['employee'] as Map<String, dynamic>),
  appointment: Appointment.fromJson(
    json['appointment'] as Map<String, dynamic>,
  ),
  serviceAmount: BigDecimal.fromJson(json['serviceAmount']),
  commissionAmount: BigDecimal.fromJson(json['commissionAmount']),
  commissionRate: BigDecimal.fromJson(json['commissionRate']),
  workDate: DateTime.parse(json['workDate'] as String),
  paymentStatus:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['paymentStatus']) ??
      PaymentStatus.PENDING,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  paidAt:
      json['paidAt'] == null ? null : DateTime.parse(json['paidAt'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SalaryRecordToJson(SalaryRecord instance) =>
    <String, dynamic>{
      'salaryRecordId': instance.salaryRecordId,
      'employee': instance.employee,
      'appointment': instance.appointment,
      'serviceAmount': instance.serviceAmount,
      'commissionAmount': instance.commissionAmount,
      'commissionRate': instance.commissionRate,
      'workDate': instance.workDate.toIso8601String(),
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'notes': instance.notes,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.PENDING: 'PENDING',
  PaymentStatus.PAID: 'PAID',
  PaymentStatus.CANCELLED: 'CANCELLED',
};
