// lib/models/booking_model.dart
class Booking {
  final int appointmentId;
  final String slug;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final DateTime createdAt;
  final String storeName;
  final String serviceName;
  final String employeeFullName;
  final double totalAmount;
  final String? notes;
  final String userFullName;

  Booking({
    required this.appointmentId,
    required this.slug,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    required this.storeName,
    required this.serviceName,
    required this.employeeFullName,
    required this.totalAmount,
    required this.userFullName,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      final storeServiceJson = json['storeService'] as Map<String, dynamic>?;
      final employeeJson = json['employee'] as Map<String, dynamic>?;
      final invoiceJson = json['invoice'] as Map<String, dynamic>?;
      final userJson = json['user'] as Map<String, dynamic>?;

      return Booking(
        appointmentId: json['appointmentId'] as int,
        slug: json['slug'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),

        // Xử lý an toàn các đối tượng lồng nhau và các trường của chúng
        storeName: storeServiceJson?['storeName'] as String? ?? 'Unknown Store',
        serviceName:
            storeServiceJson?['serviceName'] as String? ?? 'Unknown Service',

        employeeFullName:
            employeeJson?['fullName'] as String? ?? 'Unknown Employee',

        totalAmount: (invoiceJson?['totalAmount'] as num?)?.toDouble() ?? 0.0,
        userFullName: userJson?['fullName'] as String? ?? 'Unknown User',

        notes: json['notes'] as String?,
      );
    } catch (e) {
      print('Error parsing Booking from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'slug': slug,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'storeName': storeName,
      'serviceName': serviceName,
      'employeeFullName': employeeFullName,
      'totalAmount': totalAmount,
      'userFullName': userFullName,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Booking(appointmentId: $appointmentId, slug: $slug, status: $status, serviceName: $serviceName, storeName: $storeName, employeeFullName: $employeeFullName, totalAmount: $totalAmount, userFullName: $userFullName)';
  }
}
