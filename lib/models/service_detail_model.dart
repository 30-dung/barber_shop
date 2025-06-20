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

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      serviceImg: json['serviceImg'],
    );
  }
}
