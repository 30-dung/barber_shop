// ignore: depend_on_referenced_packages
import 'package:shine_booking_app/models/service_detail_model.dart';
import 'package:shine_booking_app/models/store_model.dart';

class StoreService {
  final int storeServiceId;
  final Store store;
  final ServiceDetail service; // Changed from Service to ServiceDetail
  final double price;

  StoreService({
    required this.storeServiceId,
    required this.store,
    required this.service,
    required this.price,
  });

  factory StoreService.fromJson(Map<String, dynamic> json) {
    return StoreService(
      storeServiceId: json['storeServiceId'],
      store: Store.fromJson(json['store']),
      service: ServiceDetail.fromJson(json['service']), // Use ServiceDetail
      price: json['price'].toDouble(),
    );
  }
}
