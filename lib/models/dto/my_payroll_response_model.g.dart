// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_payroll_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyPayrollResponse _$MyPayrollResponseFromJson(Map<String, dynamic> json) =>
    MyPayrollResponse(
      employee:
          json['employee'] == null
              ? null
              : Employee.fromJson(json['employee'] as Map<String, dynamic>),
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      success: json['success'] as bool,
      payrolls:
          (json['payrolls'] as List<dynamic>)
              .map((e) => PayrollSummary.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MyPayrollResponseToJson(MyPayrollResponse instance) =>
    <String, dynamic>{
      'employee': instance.employee,
      'year': instance.year,
      'month': instance.month,
      'success': instance.success,
      'payrolls': instance.payrolls,
    };
