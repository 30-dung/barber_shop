import 'package:json_annotation/json_annotation.dart';

part 'service_detail_model.g.dart';

@JsonSerializable()
class ServiceDetail {
  final int serviceId;
  final String serviceName;
  final String? description;
  final int durationMinutes;
  final String? serviceImg;

  ServiceDetail({
    required this.serviceId,
    required this.serviceName,
    this.description,
    required this.durationMinutes,
    this.serviceImg,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) =>
      _$ServiceDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceDetailToJson(this);
}
