class Salon {
  final int id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  Salon({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      imageUrl:
          json['imageUrl'] ??
          'https://via.placeholder.com/150', // Default image
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
