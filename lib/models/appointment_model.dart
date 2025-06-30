import 'package:json_annotation/json_annotation.dart';

import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/invoice_model.dart';
import 'package:shine_booking_app/models/store_service_model.dart';
import 'package:shine_booking_app/models/user_model.dart';
import 'package:shine_booking_app/models/working_time_slot_model.dart';
import 'package:shine_booking_app/models/review_target_type_model.dart'; // Added, as it's likely needed for other models or review
import 'package:shine_booking_app/models/review_model.dart'; // Added, as Appointment likely links to Review

part 'appointment_model.g.dart'; // Changed to _model.g.dart for consistency

@JsonSerializable()
class AppointmentStoreService {
  final int storeId;
  final int storeServiceId;
  final String storeName;
  final String serviceName;

  AppointmentStoreService({
    required this.storeId,
    required this.storeServiceId,
    required this.storeName,
    required this.serviceName,
  });

  factory AppointmentStoreService.fromJson(Map<String, dynamic> json) =>
      _$AppointmentStoreServiceFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentStoreServiceToJson(this);
}

// Helper class for nested Employee data in Appointment API response
@JsonSerializable()
class AppointmentEmployee {
  final int employeeId;
  final String fullName;

  AppointmentEmployee({required this.employeeId, required this.fullName});

  factory AppointmentEmployee.fromJson(Map<String, dynamic> json) =>
      _$AppointmentEmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentEmployeeToJson(this);
}

// Helper class for nested Invoice data in Appointment API response
@JsonSerializable()
class AppointmentInvoice {
  final double
  totalAmount; // Assuming totalAmount is double in JSON, adjust if BigDecimal is used here

  AppointmentInvoice({required this.totalAmount});

  factory AppointmentInvoice.fromJson(Map<String, dynamic> json) =>
      _$AppointmentInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentInvoiceToJson(this);
}

// Helper class for nested User data in Appointment API response
@JsonSerializable()
class AppointmentUser {
  final int userId;
  final String fullName;
  final String?
  phoneNumber; // Make nullable as per JSON response sometimes missing
  final String? email; // Make nullable as per JSON response sometimes missing

  AppointmentUser({
    required this.userId,
    required this.fullName,
    this.phoneNumber, // Now a named and optional parameter
    this.email, // Now a named and optional parameter
  });

  factory AppointmentUser.fromJson(Map<String, dynamic> json) =>
      _$AppointmentUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentUserToJson(this);
}

@JsonSerializable()
class Appointment {
  final int appointmentId;
  final String slug;
  final DateTime startTime;
  final DateTime endTime;
  final Status status;
  final DateTime createdAt;

  final AppointmentStoreService storeService;
  final AppointmentEmployee employee;
  final AppointmentInvoice? invoice; // Invoice có thể null
  final AppointmentUser user;

  final WorkingTimeSlot? workingSlot;
  final String? notes;
  final bool salaryCalculated;
  final DateTime? completedAt;

  Appointment({
    required this.appointmentId,
    required this.slug,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    required this.storeService,
    required this.employee,
    required this.user,
    this.invoice,
    this.workingSlot,
    this.notes,
    this.salaryCalculated = false, // Set a default value if not always in JSON
    this.completedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  // Thêm copyWith để cập nhật trạng thái cục bộ
  Appointment copyWith({
    int? appointmentId,
    String? slug,
    DateTime? startTime,
    DateTime? endTime,
    Status? status,
    DateTime? createdAt,
    AppointmentStoreService? storeService,
    AppointmentEmployee? employee,
    AppointmentInvoice? invoice,
    AppointmentUser? user,
    WorkingTimeSlot? workingSlot,
    String? notes,
    bool? salaryCalculated,
    DateTime? completedAt,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      slug: slug ?? this.slug,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      storeService: storeService ?? this.storeService,
      employee: employee ?? this.employee,
      invoice: invoice ?? this.invoice,
      user: user ?? this.user,
      workingSlot: workingSlot ?? this.workingSlot,
      notes: notes ?? this.notes,
      salaryCalculated: salaryCalculated ?? this.salaryCalculated,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum Status {
  @JsonValue('PENDING')
  PENDING,
  @JsonValue('CONFIRMED')
  CONFIRMED,
  @JsonValue('COMPLETED')
  COMPLETED,
  @JsonValue('CANCELED')
  CANCELED,
}
