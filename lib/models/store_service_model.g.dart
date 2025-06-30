// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreService _$StoreServiceFromJson(Map<String, dynamic> json) => StoreService(
  storeServiceId: (json['storeServiceId'] as num?)?.toInt(),
  store: Store.fromJson(json['store'] as Map<String, dynamic>),
  service: ServiceDetail.fromJson(json['service'] as Map<String, dynamic>),
  price: (json['price'] as num).toDouble(),
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StoreServiceToJson(StoreService instance) =>
    <String, dynamic>{
      'storeServiceId': instance.storeServiceId,
      'store': instance.store.toJson(),
      'service': instance.service.toJson(),
      'price': instance.price,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
    };
