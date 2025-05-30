// models/store_service.dart
class StoreServiceEntity {
  final int StoreServiceEntityId;
  final Store store;
  final Service service;
  final double price;

  StoreServiceEntity({
    required this.StoreServiceEntityId,
    required this.store,
    required this.service,
    required this.price,
  });

  factory StoreServiceEntity.fromJson(Map<String, dynamic> json) {
    return StoreServiceEntity(
      StoreServiceEntityId: json['StoreServiceEntityId'] ?? 0,
      store: Store.fromJson(json['store'] ?? {}),
      service: Service.fromJson(json['service'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class Store {
  final int storeId;
  final String storeName;
  final String storeImages;
  final String phoneNumber;
  final String cityProvince;
  final String district;
  final String openingTime;
  final String closingTime;
  final String description;
  final double averageRating;
  final String createdAt;

  Store({
    required this.storeId,
    required this.storeName,
    required this.storeImages,
    required this.phoneNumber,
    required this.cityProvince,
    required this.district,
    required this.openingTime,
    required this.closingTime,
    required this.description,
    required this.averageRating,
    required this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'] ?? 0,
      storeName: json['storeName'] ?? '',
      storeImages: json['storeImages'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      cityProvince: json['cityProvince'] ?? '',
      district: json['district'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      description: json['description'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Service {
  final int serviceId;
  final String serviceName;
  final String description;
  final int durationMinutes;
  final String? imageUrl; // Thêm trường imageUrl để tương thích với UI hiện tại

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.description,
    required this.durationMinutes,
    this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      description: json['description'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      imageUrl: json['imageUrl'], // API không trả về imageUrl, để null
    );
  }
}
