// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
  storeId: (json['storeId'] as num?)?.toInt(),
  storeName: json['storeName'] as String?,
  storeImages: json['storeImages'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  cityProvince: json['cityProvince'] as String?,
  district: json['district'] as String?,
  openingTime: json['openingTime'] as String?,
  closingTime: json['closingTime'] as String?,
  description: json['description'] as String?,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
  'storeId': instance.storeId,
  'storeName': instance.storeName,
  'storeImages': instance.storeImages,
  'phoneNumber': instance.phoneNumber,
  'cityProvince': instance.cityProvince,
  'district': instance.district,
  'openingTime': instance.openingTime,
  'closingTime': instance.closingTime,
  'description': instance.description,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
  'createdAt': instance.createdAt?.toIso8601String(),
};
