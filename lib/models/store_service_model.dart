import 'package:json_annotation/json_annotation.dart';
import 'package:shine_booking_app/models/store_model.dart';
import 'package:shine_booking_app/models/service_detail_model.dart';
import 'package:shine_booking_app/models/employee_model.dart';

part 'store_service_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreService {
  int? storeServiceId;
  Store store;
  ServiceDetail service;
  // API trả về price dưới dạng number, không phải BigDecimal
  double price;
  double averageRating;
  int totalReviews;

  StoreService({
    this.storeServiceId,
    required this.store,
    required this.service,
    required this.price,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory StoreService.fromJson(Map<String, dynamic> json) =>
      _$StoreServiceFromJson(json);

  get duration => null;
  Map<String, dynamic> toJson() => _$StoreServiceToJson(this);
}

// Nếu bạn vẫn muốn sử dụng BigDecimal, có thể tạo getter
extension StoreServiceExtension on StoreService {
  BigDecimal get bigDecimalPrice => BigDecimal(price.toString());
}
