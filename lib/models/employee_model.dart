class Employee {
  final int employeeId;
  final String employeeCode;
  // If you need the full nested Store object here, make sure its model is imported and used
  // final Store store; // You might not need the full store object in employee, just its ID

  final String fullName; // Corresponds to backend's "fullName"
  final String? avatarUrl; // Corresponds to backend's "avatarUrl"
  final String email;
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth; // Parse from ISO 8601 string
  final String? specialization; // Corresponds to backend's "specialization"
  final double?
  rating; // If the employee has an individual rating (from averageRating in Store, or separate API)

  // You can keep 'position' and 'description' if your UI uses them
  // and map them from backend fields or leave them as optional.
  // For now, mapping 'specialization' to 'position' for continuity.
  final String? position;
  final String? description;

  Employee({
    required this.employeeId,
    required this.employeeCode,
    // required this.store, // Include if you want the full nested Store object
    required this.fullName,
    this.avatarUrl,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.dateOfBirth,
    this.specialization,
    this.rating, // Keep if applicable from backend or calculated
    this.position,
    this.description,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'] as int,
      employeeCode: json['employeeCode'] as String,
      // store: json['store'] != null ? Store.fromJson(json['store']) : null, // Uncomment if you need the nested store
      fullName: json['fullName'] as String,
      avatarUrl:
          json['avatarUrl'] as String?, // Use as String? because it can be null
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      specialization: json['specialization'] as String?,
      // Map specialization to position for display, if desired
      position: json['specialization'] as String?,
      // Assuming 'averageRating' for employee might be directly in employee object, or default to null
      rating:
          (json['averageRating'] is num)
              ? (json['averageRating'] as num).toDouble()
              : null,
      // Assuming description might be specialization or another field
      description:
          json['description']
              as String?, // If there's a specific 'description' field for employee
    );
  }
}
