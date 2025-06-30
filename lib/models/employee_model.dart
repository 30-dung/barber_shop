import 'package:json_annotation/json_annotation.dart';
import 'package:shine_booking_app/models/role_model.dart';
import 'package:shine_booking_app/models/store_model.dart';

part 'employee_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Employee {
  int? employeeId;
  String employeeCode;
  Store store;
  List<Role> roles;
  String fullName;
  String? avatarUrl;
  String email;
  String password;
  String? phoneNumber;
  Gender? gender;
  DateTime? dateOfBirth;
  String? specialization;
  @JsonKey(fromJson: BigDecimal.fromJson, toJson: _bigDecimalToJson)
  BigDecimal baseSalary;
  @JsonKey(fromJson: BigDecimal.fromJson, toJson: _bigDecimalToJson)
  BigDecimal commissionRate;
  SalaryType salaryType;
  bool isActive;
  @JsonKey(fromJson: BigDecimal.fromJson, toJson: _bigDecimalToJson)
  BigDecimal averageRating;
  int totalReviews;
  DateTime? createdAt;
  DateTime? updatedAt;

  Employee({
    this.employeeId,
    required this.employeeCode,
    required this.store,
    required this.roles,
    required this.fullName,
    this.avatarUrl,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.specialization,
    required this.baseSalary,
    required this.commissionRate,
    required this.salaryType,
    this.isActive = true,
    this.averageRating = const BigDecimal('0.00'),
    this.totalReviews = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  // TRIỂN KHAI PHƯƠNG THỨC copyWith
  Employee copyWith({
    int? employeeId,
    String? employeeCode,
    Store? store,
    List<Role>? roles,
    String? fullName,
    String? avatarUrl,
    String? email,
    String? password,
    String? phoneNumber,
    Gender? gender,
    DateTime? dateOfBirth,
    String? specialization,
    BigDecimal? baseSalary,
    BigDecimal? commissionRate,
    SalaryType? salaryType,
    bool? isActive,
    BigDecimal? averageRating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      store: store ?? this.store,
      roles: roles ?? this.roles,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specialization: specialization ?? this.specialization,
      baseSalary: baseSalary ?? this.baseSalary,
      commissionRate: commissionRate ?? this.commissionRate,
      salaryType: salaryType ?? this.salaryType,
      isActive: isActive ?? this.isActive,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String _bigDecimalToJson(BigDecimal value) => value.toJson();

enum Gender { MALE, FEMALE, OTHER }

enum SalaryType { FIXED, COMMISSION, MIXED }

// Extension để convert SalaryType sang Vietnamese
extension SalaryTypeExtension on SalaryType {
  String get displayName {
    switch (this) {
      case SalaryType.FIXED:
        return 'Lương cố định';
      case SalaryType.COMMISSION:
        return 'Lương hoa hồng';
      case SalaryType.MIXED:
        return 'Lương hỗn hợp';
    }
  }
}

// Extension để convert Gender sang Vietnamese
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.MALE:
        return 'Nam';
      case Gender.FEMALE:
        return 'Nữ';
      case Gender.OTHER:
        return 'Khác';
    }
  }
}

// TRIỂN KHAI LẠI LỚP BigDecimal ĐỂ CÓ scale VÀ toBigInt()
class BigDecimal {
  final String value;
  const BigDecimal(this.value);

  factory BigDecimal.fromJson(dynamic json) {
    if (json == null) {
      return const BigDecimal('0.00');
    }
    if (json is String) {
      return BigDecimal(json);
    } else if (json is double) {
      if (json == json.toInt().toDouble()) {
        return BigDecimal(json.toInt().toString());
      }
      return BigDecimal(json.toString());
    } else if (json is int) {
      return BigDecimal(json.toString());
    }
    print('Warning: Invalid format for BigDecimal: $json. Defaulting to 0.00');
    return const BigDecimal('0.00');
  }

  int get scale {
    if (value.contains('.')) {
      return value.length - value.indexOf('.') - 1;
    }
    return 0;
  }

  String toJson() => value;

  double toDouble() {
    try {
      return double.parse(value);
    } catch (e) {
      print('Error parsing BigDecimal "$value" to double: $e');
      return 0.0;
    }
  }

  BigInt toBigInt() {
    try {
      if (value.contains('.')) {
        return BigInt.parse(value.substring(0, value.indexOf('.')));
      }
      return BigInt.parse(value);
    } catch (e) {
      print('Error parsing BigDecimal "$value" to BigInt: $e');
      return BigInt.zero;
    }
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigDecimal && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
