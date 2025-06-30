// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentStoreService _$AppointmentStoreServiceFromJson(
  Map<String, dynamic> json,
) => AppointmentStoreService(
  storeId: (json['storeId'] as num).toInt(),
  storeServiceId: (json['storeServiceId'] as num).toInt(),
  storeName: json['storeName'] as String,
  serviceName: json['serviceName'] as String,
);

Map<String, dynamic> _$AppointmentStoreServiceToJson(
  AppointmentStoreService instance,
) => <String, dynamic>{
  'storeId': instance.storeId,
  'storeServiceId': instance.storeServiceId,
  'storeName': instance.storeName,
  'serviceName': instance.serviceName,
};

AppointmentEmployee _$AppointmentEmployeeFromJson(Map<String, dynamic> json) =>
    AppointmentEmployee(
      employeeId: (json['employeeId'] as num).toInt(),
      fullName: json['fullName'] as String,
    );

Map<String, dynamic> _$AppointmentEmployeeToJson(
  AppointmentEmployee instance,
) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'fullName': instance.fullName,
};

AppointmentInvoice _$AppointmentInvoiceFromJson(Map<String, dynamic> json) =>
    AppointmentInvoice(totalAmount: (json['totalAmount'] as num).toDouble());

Map<String, dynamic> _$AppointmentInvoiceToJson(AppointmentInvoice instance) =>
    <String, dynamic>{'totalAmount': instance.totalAmount};

AppointmentUser _$AppointmentUserFromJson(Map<String, dynamic> json) =>
    AppointmentUser(
      userId: (json['userId'] as num).toInt(),
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$AppointmentUserToJson(AppointmentUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
    };

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  appointmentId: (json['appointmentId'] as num).toInt(),
  slug: json['slug'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$StatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  storeService: AppointmentStoreService.fromJson(
    json['storeService'] as Map<String, dynamic>,
  ),
  employee: AppointmentEmployee.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  user: AppointmentUser.fromJson(json['user'] as Map<String, dynamic>),
  invoice:
      json['invoice'] == null
          ? null
          : AppointmentInvoice.fromJson(
            json['invoice'] as Map<String, dynamic>,
          ),
  workingSlot:
      json['workingSlot'] == null
          ? null
          : WorkingTimeSlot.fromJson(
            json['workingSlot'] as Map<String, dynamic>,
          ),
  notes: json['notes'] as String?,
  salaryCalculated: json['salaryCalculated'] as bool? ?? false,
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'slug': instance.slug,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': _$StatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'storeService': instance.storeService,
      'employee': instance.employee,
      'invoice': instance.invoice,
      'user': instance.user,
      'workingSlot': instance.workingSlot,
      'notes': instance.notes,
      'salaryCalculated': instance.salaryCalculated,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$StatusEnumMap = {
  Status.PENDING: 'PENDING',
  Status.CONFIRMED: 'CONFIRMED',
  Status.COMPLETED: 'COMPLETED',
  Status.CANCELED: 'CANCELED',
};
