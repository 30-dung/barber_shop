class User {
  final String id;
  final String name;
  final String phone;

  User({required this.id, required this.name, required this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], phone: json['phone']);
  }
}
