// lib/models/store_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart';

@JsonSerializable()
class Store {
  @JsonKey(name: 'storeId')
  int? storeId;

  @JsonKey(name: 'storeName')
  String? storeName;

  @JsonKey(name: 'storeImages')
  String? storeImages;

  @JsonKey(name: 'phoneNumber')
  String? phoneNumber;

  @JsonKey(name: 'cityProvince')
  String? cityProvince;

  @JsonKey(name: 'district')
  String? district;

  @JsonKey(name: 'openingTime')
  String? openingTime;

  @JsonKey(name: 'closingTime')
  String? closingTime;

  @JsonKey(name: 'description')
  String? description;

  @JsonKey(name: 'averageRating')
  double? averageRating;

  @JsonKey(name: 'totalReviews')
  int? totalReviews;

  @JsonKey(name: 'createdAt')
  DateTime? createdAt;

  Store({
    this.storeId,
    this.storeName,
    this.storeImages,
    this.phoneNumber,
    this.cityProvince,
    this.district,
    this.openingTime,
    this.closingTime,
    this.description,
    this.averageRating,
    this.totalReviews,
    this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
