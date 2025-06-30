// lib/models/dto/my_payroll_response_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../employee_model.dart';
import '../payroll_summary_model.dart';

part 'my_payroll_response_model.g.dart';

@JsonSerializable()
class MyPayrollResponse {
  @JsonKey(name: 'employee')
  final Employee? employee;

  @JsonKey(name: 'year')
  final int year;

  @JsonKey(name: 'month')
  final int month;

  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'payrolls')
  final List<PayrollSummary> payrolls;

  MyPayrollResponse({
    this.employee,
    required this.year,
    required this.month,
    required this.success,
    required this.payrolls,
  });

  factory MyPayrollResponse.fromJson(Map<String, dynamic> json) =>
      _$MyPayrollResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MyPayrollResponseToJson(this);
}
