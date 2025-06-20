// lib/models/working_time_slot_model.dart
class WorkingTimeSlot {
  final int timeSlotId;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  WorkingTimeSlot({
    required this.timeSlotId,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  factory WorkingTimeSlot.fromJson(Map<String, dynamic> json) {
    return WorkingTimeSlot(
      timeSlotId: json['timeSlotId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlotId': timeSlotId,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}
