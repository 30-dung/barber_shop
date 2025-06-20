// lib/models/user_model.dart
class User {
  final int? userId; // User ID, nullable for flexibility
  final String fullName;
  final String email;
  final String phoneNumber;
  final String?
  password; // Made nullable for security reasons (not to store in SharedPreferences)
  final String membershipType;
  final int? loyaltyPoints; // Loyalty points, nullable
  final String? createdAt; // Creation timestamp, nullable
  final String?
  avatar; // Optional: If you have an avatar URL in the user profile

  User({
    this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password, // This is now optional in the constructor
    required this.membershipType,
    this.loyaltyPoints,
    this.createdAt,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Print the incoming JSON for debugging purposes. Remove in production.
    print('User.fromJson received JSON for parsing: $json');

    try {
      return User(
        // Safely parse userId, trying multiple common keys
        userId:
            json['userId'] as int? ??
            json['id'] as int? ??
            json['user_id'] as int?,

        // Safely parse fullName, trying multiple common keys
        fullName:
            json['fullName'] as String? ??
            json['full_name'] as String? ??
            json['name'] as String? ??
            '',

        email: json['email'] as String? ?? '', // Safely parse email
        phoneNumber:
            json['phoneNumber'] as String? ?? '', // Safely parse phone number
        // Password is often not returned by login/profile APIs. Handle as nullable.
        password:
            json['password']
                as String?, // Keep as nullable string. Do NOT require.

        membershipType:
            json['membershipType'] as String? ??
            '', // Safely parse membershipType
        // Safely parse loyaltyPoints (can be int or num from JSON)
        loyaltyPoints:
            (json['loyaltyPoints'] is num)
                ? (json['loyaltyPoints'] as num).toInt()
                : null, // Default to null if not a number

        createdAt: json['createdAt'] as String?, // Safely parse createdAt
        // Safely parse avatar URL, trying common keys
        avatar: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      );
    } catch (e) {
      // Log errors during parsing to the console
      print('❌ Lỗi parse User từ JSON: $e');
      print('JSON data that caused error: $json');
      // Re-throw the exception to propagate it up the call stack for error handling in UI/logic
      rethrow;
    }
  }

  // *** THIS IS THE MISSING toJson() METHOD ***
  // Converts User object to a JSON-compatible Map.
  // Sensitive data like 'password' should generally be omitted here for storage in SharedPreferences.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'membershipType': membershipType,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt,
      'avatar': avatar,
    };
    // Only include password if it's specifically needed for an outgoing request (e.g., registration)
    // and is not null. It should NOT be stored in shared preferences.
    // if (password != null) {
    //   data['password'] = password;
    // }
    return data;
  }

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, membershipType: $membershipType, loyaltyPoints: $loyaltyPoints, createdAt: $createdAt, avatar: $avatar)';
  }
}
