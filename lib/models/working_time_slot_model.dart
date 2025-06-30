import 'package:json_annotation/json_annotation.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/store_model.dart';

part 'working_time_slot_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkingTimeSlot {
  int? timeSlotId;
  Employee? employee;
  Store? store;
  DateTime? startTime;
  DateTime? endTime;
  bool? isAvailable;

  WorkingTimeSlot({
    this.timeSlotId,
    this.employee,
    this.store,
    this.startTime,
    this.endTime,
    this.isAvailable,
  });

  factory WorkingTimeSlot.fromJson(Map<String, dynamic> json) =>
      _$WorkingTimeSlotFromJson(json);
  Map<String, dynamic> toJson() => _$WorkingTimeSlotToJson(this);
}
