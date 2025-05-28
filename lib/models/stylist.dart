class Stylist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bio;
  final String? salonId; // Có thể liên kết với salon

  Stylist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    this.salonId,
  });

  // Factory constructor để tạo Stylist từ Map (ví dụ từ JSON)
  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      bio: json['bio'] as String?,
      salonId: json['salonId'] as String?,
    );
  }

  // Method để chuyển đổi Stylist thành Map (ví dụ để gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'bio': bio,
      'salonId': salonId,
    };
  }
}
