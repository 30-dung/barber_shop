import 'dart:convert';

// Define UserRole enum for distinct user types
enum UserRole {
  customer,
  employee,
  admin,
}

class User {
  final int? userId; // User ID, nullable for flexibility
  String fullName;
  String email;
  String phoneNumber;
  final String? password; // Made nullable for security reasons (not to store in SharedPreferences)
  final UserRole role; // Added role property
  final String membershipType;
  final int? loyaltyPoints; // Loyalty points, nullable
  final String? createdAt; // Creation timestamp, nullable
  // final String? avatar; // Optional: If you have an avatar URL in the user profile - REMOVED

  User({
    this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
    required this.role, // Added to constructor
    required this.membershipType,
    this.loyaltyPoints,
    this.createdAt,
    // this.avatar, // REMOVED
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('User.fromJson received JSON for parsing: $json');

    try {
      // Safely parse role, defaulting to customer if not found or invalid
      UserRole parsedRole;
      try {
        String? roleStringFromBackend = json['role'] as String?;
        String cleanRoleString = 'customer'; // Default if null or unhandled

        if (roleStringFromBackend != null) {
          // Remove "ROLE_" prefix if present and convert to lowercase
          if (roleStringFromBackend.startsWith('ROLE_')) {
            cleanRoleString = roleStringFromBackend.substring(5).toLowerCase();
          } else {
            cleanRoleString = roleStringFromBackend.toLowerCase();
          }
        }

        parsedRole = UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == cleanRoleString,
          orElse: () => UserRole.customer,
        );
      } catch (e) {
        print('Warning: Failed to parse user role from JSON: $e. Defaulting to customer.');
        parsedRole = UserRole.customer;
      }


      return User(
        userId:
        json['userId'] as int? ?? json['id'] as int? ?? json['user_id'] as int?,
        fullName:
        json['fullName'] as String? ?? json['full_name'] as String? ?? json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber:
        json['phoneNumber'] as String? ?? '',
        password:
        json['password'] as String?,
        role: parsedRole, // Assign the parsed role
        membershipType:
        json['membershipType'] as String? ?? 'Standard', // Default if missing
        loyaltyPoints:
        (json['loyaltyPoints'] is num)
            ? (json['loyaltyPoints'] as num).toInt()
            : 0, // Default to 0 if not a number
        createdAt: json['createdAt'] as String?,
        // avatar: json['avatarUrl'] as String? ?? json['avatar'] as String?, // REMOVED
      );
    } catch (e) {
      print('❌ Lỗi parse User từ JSON: $e');
      print('JSON data that caused error: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last, // Convert enum to string
      'membershipType': membershipType,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt,
      // 'avatar': avatar, // REMOVED
    };
    return data;
  }

  @override
  String toString() {
    return 'User(userId: $userId, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, role: ${role.toString().split('.').last}, membershipType: $membershipType, loyaltyPoints: $loyaltyPoints, createdAt: $createdAt)';
    // Removed avatar from toString()
  }
}
