import 'package:shine_booking_app/models/user_model.dart'; // Import UserRole enum

class Employee {
  final int employeeId;
  final String employeeCode;
  final String fullName;
  final String? avatarUrl;
  final String email;
  final String?
  password; // Made nullable as it shouldn't be stored/passed after login
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth;
  final String? specialization;
  final double? rating;
  final String? position;
  final String? description;
  final UserRole role; // << THÊM TRƯỜNG ROLE Ở ĐÂY

  Employee({
    required this.employeeId,
    required this.employeeCode,
    required this.fullName,
    this.avatarUrl,
    required this.email,
    this.password, // This is now optional in the constructor
    required this.phoneNumber,
    required this.gender,
    this.dateOfBirth,
    this.specialization,
    this.rating,
    this.position,
    this.description,
    required this.role, // << THÊM VÀO CONSTRUCTOR
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Parse role from JSON. Need to know the key for role in the JSON response from backend.
    // Example: if backend returns {"role": "ROLE_EMPLOYEE"} or {"roleName": "employee"}
    String roleStringFromBackend =
        json['role'] as String? ?? // Assuming key is 'role'
        json['roleName'] as String? ?? // Or 'roleName'
        'employee'; // Default to 'employee' if not present

    // Standardize the role string (e.g., "ROLE_EMPLOYEE" -> "employee")
    if (roleStringFromBackend.startsWith('ROLE_')) {
      roleStringFromBackend = roleStringFromBackend.substring(5).toLowerCase();
    } else {
      roleStringFromBackend = roleStringFromBackend.toLowerCase();
    }

    UserRole parsedRole = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleStringFromBackend,
      orElse: () {
        print(
          'Warning: Unrecognized role "$roleStringFromBackend" from backend for employee. Defaulting to employee.',
        );
        return UserRole.employee; // Or another suitable default role
      },
    );

    return Employee(
      employeeId: json['employeeId'] as int,
      employeeCode: json['employeeCode'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?, // Made nullable, handle with care
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      specialization: json['specialization'] as String?,
      position:
          json['specialization']
              as String?, // Assuming specialization maps to position for display
      rating:
          (json['averageRating'] is num)
              ? (json['averageRating'] as num).toDouble()
              : null,
      description: json['description'] as String?,
      role: parsedRole, // << USE PARSED ROLE
    );
  }

  get createdAt => null;

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'email': email,
      // 'password': password, // Generally omit password from toJson for storage/profile
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'specialization': specialization,
      'position': position,
      'rating': rating,
      'description': description,
      'role': role.toString().split('.').last, // << CONVERT ROLE ENUM TO STRING
    };
  }

  // (Optional) Add copyWith if needed for immutable updates
  Employee copyWith({
    int? employeeId,
    String? employeeCode,
    String? fullName,
    String? avatarUrl,
    String? email,
    String?
    password, // Include password if needed for specific copy operations, but be mindful
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? specialization,
    double? rating,
    String? position,
    String? description,
    UserRole? role,
  }) {
    return Employee(
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      position: position ?? this.position,
      description: description ?? this.description,
      role: role ?? this.role,
    );
  }
}
