import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Invoice {
  final int invoiceId;
  final String status;
  final double totalAmount;
  final String createdAt;
  final String? userFullName;
  final List<InvoiceAppointmentDetail> appointmentDetails;

  Invoice({
    required this.invoiceId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.userFullName,
    required this.appointmentDetails,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  // Các getter cho UI
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'PAID':
        return 'Đã thanh toán';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PAID':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get formattedCreatedAt {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return createdAt;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String get formattedTotalAmount {
    return '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} đ';
  }
}

@JsonSerializable()
class InvoiceAppointmentDetail {
  final int appointmentId;
  final String? serviceName;
  final String? employeeFullName;
  final String? startTime;
  final String? endTime;
  final double price;

  InvoiceAppointmentDetail({
    required this.appointmentId,
    this.serviceName,
    this.employeeFullName,
    this.startTime,
    this.endTime,
    required this.price,
  });

  factory InvoiceAppointmentDetail.fromJson(Map<String, dynamic> json) =>
      _$InvoiceAppointmentDetailFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceAppointmentDetailToJson(this);

  String get formattedPrice =>
      '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} đ';

  String get formattedDate {
    if (startTime == null) return '';
    final dt = DateTime.tryParse(startTime!);
    if (dt == null) return startTime!;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String get formattedTimeRange {
    if (startTime == null || endTime == null) return '';
    final st = DateTime.tryParse(startTime!);
    final et = DateTime.tryParse(endTime!);
    if (st == null || et == null) return '';
    String formatTime(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${formatTime(st)} - ${formatTime(et)}';
  }
}
