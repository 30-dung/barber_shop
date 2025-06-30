import 'package:json_annotation/json_annotation.dart';
import 'package:shine_booking_app/models/employee_model.dart'; // Corrected path
import 'package:shine_booking_app/models/appointment_model.dart'; // Corrected path

part 'salary_record_model.g.dart'; // Changed to _model.g.dart for consistency

@JsonSerializable()
class SalaryRecord {
  int? salaryRecordId;
  Employee employee;
  Appointment appointment;
  BigDecimal serviceAmount;
  BigDecimal commissionAmount;
  BigDecimal commissionRate;
  DateTime workDate;
  PaymentStatus paymentStatus;
  DateTime? createdAt;
  DateTime? paidAt;
  String? notes;

  SalaryRecord({
    this.salaryRecordId,
    required this.employee,
    required this.appointment,
    required this.serviceAmount,
    required this.commissionAmount,
    required this.commissionRate,
    required this.workDate,
    this.paymentStatus = PaymentStatus.PENDING,
    this.createdAt,
    this.paidAt,
    this.notes,
  });

  factory SalaryRecord.fromJson(Map<String, dynamic> json) =>
      _$SalaryRecordFromJson(json);
  Map<String, dynamic> toJson() => _$SalaryRecordToJson(this);
}

enum PaymentStatus {
  @JsonValue('PENDING')
  PENDING,
  @JsonValue('PAID')
  PAID,
  @JsonValue('CANCELLED')
  CANCELLED,
}
