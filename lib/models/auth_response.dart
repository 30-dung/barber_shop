class AuthResponse {
  final String? token; // Token for successful login/registration
  final String? message; // General message (success or error)
  final String? role; // User role, if provided by backend on login

  AuthResponse({this.token, this.message, this.role});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      message: json['message'],
      role: json['role'],
    );
  }
}
