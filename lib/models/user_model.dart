import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { customer, employee, admin }

@JsonSerializable()
class User {
  final int? userId;
  String fullName;
  String email;
  String phoneNumber;
  final String? password;
  final UserRole role;
  final String membershipType;
  final int? loyaltyPoints;
  final String? createdAt;

  User({
    this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
    required this.role,
    required this.membershipType,
    this.loyaltyPoints,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Xử lý role trả về từ API
    String? roleStr = json['role']?.toString().toLowerCase();
    if (roleStr != null && roleStr.startsWith('role_')) {
      roleStr = roleStr.replaceFirst('role_', '');
    }
    UserRole role = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => UserRole.customer,
    );
    return User(
      userId: json['userId'] as int?,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'],
      role: role,
      membershipType: json['membershipType'] ?? '',
      loyaltyPoints: json['loyaltyPoints'] as int?,
      createdAt: json['createdAt'],
    );
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
