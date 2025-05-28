import 'package:barber_app/models/service.dart';

class Booking {
  final int id;
  final String customerName;
  final String phone;
  final DateTime date;
  final String time;
  final List<Service> services;
  final String status;

  Booking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.date,
    required this.time,
    required this.services,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      customerName: json['customerName'],
      phone: json['phone'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      services:
          (json['services'] as List).map((s) => Service.fromJson(s)).toList(),
      status: json['status'],
    );
  }
}
