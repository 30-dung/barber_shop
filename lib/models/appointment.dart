// models/appointment.dart
class Appointment {
  final int id;
  final String serviceName;
  final String date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final startTime = DateTime.parse(json['startTime'] as String);
    return Appointment(
      id: json['appointmentId'] ?? 0,
      serviceName:
          json['storeService']['service']['serviceName'] ?? 'Không xác định',
      date:
          "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}",
      time:
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
      status: json['status'] ?? 'Không xác định',
    );
  }
}
