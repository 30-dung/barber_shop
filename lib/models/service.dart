class Service {
  final int id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String imageUrl;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      duration: json['duration'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
