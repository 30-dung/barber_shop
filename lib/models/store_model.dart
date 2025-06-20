class Store {
  final int id; // maps to "storeId"
  final String name; // maps to "storeName"
  final String city; // maps to "cityProvince"
  final String district; // maps to "district"
  final String phoneNumber; // maps to "phoneNumber"
  final String? storeImages; // maps to "storeImages"
  final String openingTime; // maps to "openingTime"
  final String closingTime; // maps to "closingTime"
  final String description; // maps to "description"
  final double averageRating; // maps to "averageRating"
  final String createdAt; // maps to "createdAt"

  Store({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.phoneNumber,
    this.storeImages,
    required this.openingTime,
    required this.closingTime,
    required this.description,
    required this.averageRating,
    required this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['storeId'] ?? 0,
      name: json['storeName'] ?? '',
      city: json['cityProvince'] ?? '',
      district: json['district'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      storeImages: json['storeImages']?.toString(),
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      description: json['description'] ?? '',
      averageRating:
          (json['averageRating'] is num)
              ? (json['averageRating'] as num).toDouble()
              : double.tryParse(json['averageRating']?.toString() ?? '') ?? 0.0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
