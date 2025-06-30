// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  invoiceId: (json['invoiceId'] as num).toInt(),
  status: json['status'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  createdAt: json['createdAt'] as String,
  userFullName: json['userFullName'] as String?,
  appointmentDetails:
      (json['appointmentDetails'] as List<dynamic>)
          .map(
            (e) => InvoiceAppointmentDetail.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'invoiceId': instance.invoiceId,
  'status': instance.status,
  'totalAmount': instance.totalAmount,
  'createdAt': instance.createdAt,
  'userFullName': instance.userFullName,
  'appointmentDetails':
      instance.appointmentDetails.map((e) => e.toJson()).toList(),
};

InvoiceAppointmentDetail _$InvoiceAppointmentDetailFromJson(
  Map<String, dynamic> json,
) => InvoiceAppointmentDetail(
  appointmentId: (json['appointmentId'] as num).toInt(),
  serviceName: json['serviceName'] as String?,
  employeeFullName: json['employeeFullName'] as String?,
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$InvoiceAppointmentDetailToJson(
  InvoiceAppointmentDetail instance,
) => <String, dynamic>{
  'appointmentId': instance.appointmentId,
  'serviceName': instance.serviceName,
  'employeeFullName': instance.employeeFullName,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'price': instance.price,
};
