// lib/models/location_count_model.dart
class LocationCount {
  final String name;
  final int count;

  LocationCount({required this.name, required this.count});

  factory LocationCount.fromJson(Map<String, dynamic> json) {
    // Debug: In ra JSON để xem structure thực tế
    print('LocationCount JSON: $json');

    return LocationCount(
      // Thử nhiều key có thể có
      name:
          json['cityProvince'] ??
          json['name'] ??
          json['city'] ??
          json['province'] ??
          json['district'] ??
          'N/A',
      count:
          json['storeCount'] ??
          json['count'] ??
          json['total'] ??
          json['totalStores'] ??
          0,
    );
  }

  @override
  String toString() {
    return 'LocationCount{name: $name, count: $count}';
  }
}
