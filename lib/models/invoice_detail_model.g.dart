// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceDetail _$InvoiceDetailFromJson(Map<String, dynamic> json) =>
    InvoiceDetail(
      invoiceDetailId: (json['invoiceDetailId'] as num?)?.toInt(),
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      appointment: Appointment.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      employeeId: (json['employeeId'] as num?)?.toInt(),
      storeServiceId: (json['storeServiceId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InvoiceDetailToJson(InvoiceDetail instance) =>
    <String, dynamic>{
      'invoiceDetailId': instance.invoiceDetailId,
      'invoiceId': instance.invoiceId,
      'appointment': instance.appointment.toJson(),
      'unitPrice': instance.unitPrice,
      'employeeId': instance.employeeId,
      'storeServiceId': instance.storeServiceId,
    };
