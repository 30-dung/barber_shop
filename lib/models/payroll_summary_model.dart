// lib/models/payroll_summary_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'employee_model.dart';

part 'payroll_summary_model.g.dart';

@JsonSerializable()
class PayrollSummary {
  @JsonKey(name: 'payrollId')
  int? payrollId;

  @JsonKey(name: 'employee')
  Employee? employee;

  @JsonKey(name: 'periodStartDate')
  DateTime periodStartDate;

  @JsonKey(name: 'periodEndDate')
  DateTime periodEndDate;

  @JsonKey(name: 'baseSalary')
  double baseSalary;

  @JsonKey(name: 'totalCommission')
  double totalCommission;

  @JsonKey(name: 'totalAmount')
  double totalAmount;

  @JsonKey(name: 'totalAppointments')
  int totalAppointments;

  @JsonKey(name: 'totalRevenue')
  double totalRevenue;

  @JsonKey(name: 'status')
  PayrollStatus status;

  @JsonKey(name: 'createdAt')
  DateTime? createdAt;

  @JsonKey(name: 'approvedAt')
  DateTime? approvedAt;

  @JsonKey(name: 'paidAt')
  DateTime? paidAt;

  @JsonKey(name: 'approvedBy')
  Employee? approvedBy;

  @JsonKey(name: 'notes')
  String? notes;

  PayrollSummary({
    this.payrollId,
    this.employee,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.baseSalary,
    required this.totalCommission,
    required this.totalAmount,
    required this.totalAppointments,
    required this.totalRevenue,
    this.status = PayrollStatus.DRAFT,
    this.createdAt,
    this.approvedAt,
    this.paidAt,
    this.approvedBy,
    this.notes,
  });

  factory PayrollSummary.fromJson(Map<String, dynamic> json) =>
      _$PayrollSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$PayrollSummaryToJson(this);
}

enum PayrollStatus {
  @JsonValue('DRAFT')
  DRAFT,
  @JsonValue('PENDING')
  PENDING,
  @JsonValue('APPROVED')
  APPROVED,
  @JsonValue('PAID')
  PAID,
  @JsonValue('CANCELLED')
  CANCELLED,
}
