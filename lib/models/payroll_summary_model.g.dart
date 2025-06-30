// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayrollSummary _$PayrollSummaryFromJson(Map<String, dynamic> json) =>
    PayrollSummary(
      payrollId: (json['payrollId'] as num?)?.toInt(),
      employee:
          json['employee'] == null
              ? null
              : Employee.fromJson(json['employee'] as Map<String, dynamic>),
      periodStartDate: DateTime.parse(json['periodStartDate'] as String),
      periodEndDate: DateTime.parse(json['periodEndDate'] as String),
      baseSalary: (json['baseSalary'] as num).toDouble(),
      totalCommission: (json['totalCommission'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalAppointments: (json['totalAppointments'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      status:
          $enumDecodeNullable(_$PayrollStatusEnumMap, json['status']) ??
          PayrollStatus.DRAFT,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      approvedAt:
          json['approvedAt'] == null
              ? null
              : DateTime.parse(json['approvedAt'] as String),
      paidAt:
          json['paidAt'] == null
              ? null
              : DateTime.parse(json['paidAt'] as String),
      approvedBy:
          json['approvedBy'] == null
              ? null
              : Employee.fromJson(json['approvedBy'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PayrollSummaryToJson(PayrollSummary instance) =>
    <String, dynamic>{
      'payrollId': instance.payrollId,
      'employee': instance.employee,
      'periodStartDate': instance.periodStartDate.toIso8601String(),
      'periodEndDate': instance.periodEndDate.toIso8601String(),
      'baseSalary': instance.baseSalary,
      'totalCommission': instance.totalCommission,
      'totalAmount': instance.totalAmount,
      'totalAppointments': instance.totalAppointments,
      'totalRevenue': instance.totalRevenue,
      'status': _$PayrollStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'notes': instance.notes,
    };

const _$PayrollStatusEnumMap = {
  PayrollStatus.DRAFT: 'DRAFT',
  PayrollStatus.PENDING: 'PENDING',
  PayrollStatus.APPROVED: 'APPROVED',
  PayrollStatus.PAID: 'PAID',
  PayrollStatus.CANCELLED: 'CANCELLED',
};
