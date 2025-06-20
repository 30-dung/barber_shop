// lib/models/invoice_model.dart
import 'package:flutter/material.dart'; // Import để dùng Color
import 'package:intl/intl.dart';

class Invoice {
  final int invoiceId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? userFullName; // Đặt là nullable String?
  final List<InvoiceAppointmentDetail> appointmentDetails;

  Invoice({
    required this.invoiceId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.userFullName, // Không còn required ở đây
    required this.appointmentDetails,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var appointmentDetailsList =
        json['appointments']
            as List?; // Tên trường là 'appointments' không phải 'appointmentDetails'
    List<InvoiceAppointmentDetail> details =
        appointmentDetailsList != null
            ? appointmentDetailsList
                .map((i) => InvoiceAppointmentDetail.fromJson(i))
                .toList()
            : [];

    // Lấy fullName từ đối tượng user lồng bên trong
    String? parsedUserFullName;
    if (json.containsKey('user') && json['user'] != null) {
      parsedUserFullName =
          json['user']['fullName'] as String?; // Lấy fullName từ đối tượng user
    }

    return Invoice(
      invoiceId: json['invoiceId'] as int,
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userFullName: parsedUserFullName, // Gán giá trị đã parse
      appointmentDetails: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'userFullName': userFullName, // Giữ nguyên cho việc serialize
      'appointmentDetails': appointmentDetails.map((x) => x.toJson()).toList(),
    };
  }

  String get formattedTotalAmount =>
      NumberFormat('#,###', 'vi_VN').format(totalAmount) + 'đ';

  String get formattedCreatedAt =>
      DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'PAID':
        return 'Đã thanh toán';
      case 'CANCELED':
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
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class InvoiceAppointmentDetail {
  final int appointmentId;
  final String? serviceName; // Có thể là null
  final String? employeeFullName; // Có thể là null
  final String? startTime; // Có thể là null (nếu cuộc hẹn bị hủy sớm)
  final String? endTime; // Có thể là null
  final double price;

  InvoiceAppointmentDetail({
    required this.appointmentId,
    this.serviceName,
    this.employeeFullName,
    this.startTime,
    this.endTime,
    required this.price,
  });

  factory InvoiceAppointmentDetail.fromJson(Map<String, dynamic> json) {
    // Lấy serviceName từ storeService.service.serviceName
    String? parsedServiceName;
    if (json.containsKey('storeService') &&
        json['storeService'] != null &&
        json['storeService'].containsKey('service') &&
        json['storeService']['service'] != null) {
      parsedServiceName =
          json['storeService']['service']['serviceName'] as String?;
    }

    // Lấy employeeFullName từ employee.fullName
    String? parsedEmployeeFullName;
    if (json.containsKey('employee') && json['employee'] != null) {
      parsedEmployeeFullName = json['employee']['fullName'] as String?;
    }

    return InvoiceAppointmentDetail(
      appointmentId: json['appointmentId'] as int,
      serviceName: parsedServiceName,
      employeeFullName: parsedEmployeeFullName,
      startTime: json['startTime'] as String?, // Đặt là nullable
      endTime: json['endTime'] as String?, // Đặt là nullable
      price:
          (json['storeService']['price'] as num)
              .toDouble(), // Lấy giá từ storeService
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'serviceName': serviceName,
      'employeeFullName': employeeFullName,
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
    };
  }

  String get formattedPrice =>
      NumberFormat('#,###', 'vi_VN').format(price) + 'đ';

  String get formattedTimeRange {
    if (startTime == null || endTime == null) {
      return 'N/A';
    }
    try {
      return '${DateFormat('HH:mm').format(DateTime.parse(startTime!))} - ${DateFormat('HH:mm').format(DateTime.parse(endTime!))}';
    } catch (e) {
      return 'Invalid Time';
    }
  }

  String get formattedDate {
    if (startTime == null) {
      return 'N/A';
    }
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(startTime!));
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
