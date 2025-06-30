// lib/models/dto/work_time_registration_request.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart'; // Import this for DateFormat

part 'work_time_registration_request.g.dart';

@JsonSerializable()
class WorkTimeRegistrationRequest {
  final int employeeId;
  final int storeId;
  final String startTime; // Định dạng: "2025-06-29T08:00:00"
  final String endTime; // Định dạng: "2025-06-29T13:00:00"

  WorkTimeRegistrationRequest({
    required this.employeeId,
    required this.storeId,
    required this.startTime,
    required this.endTime,
  });

  // Constructor helper để tạo từ date và time strings
  factory WorkTimeRegistrationRequest.fromDateAndTime({
    required int employeeId,
    required int storeId,
    required String date, // "2025-06-29"
    required String startTimeOnly, // "08:00"
    required String endTimeOnly, // "13:00"
  }) {
    // Tạo đối tượng DateTime đầy đủ từ ngày và thời gian
    final startDateTime = DateTime.parse('${date}T$startTimeOnly:00');
    final endDateTime = DateTime.parse('${date}T$endTimeOnly:00');

    // Định dạng lại sang chuỗi ISO 8601 đầy đủ với giây
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

    return WorkTimeRegistrationRequest(
      employeeId: employeeId,
      storeId: storeId,
      startTime: formatter.format(startDateTime),
      endTime: formatter.format(endDateTime),
    );
  }

  factory WorkTimeRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkTimeRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkTimeRegistrationRequestToJson(this);
}
