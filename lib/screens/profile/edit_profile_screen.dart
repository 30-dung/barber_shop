import 'package:flutter/material.dart';
import 'package:shine_booking_app/services/api_user.dart';
// import '../../services/api_service.dart'; // REMOVE this import
import '../../services/storage_service.dart';
import '../../models/user_model.dart';

// Reuse color constants for consistency
const Color kPrimaryColor = Color(0xFFFF6B35);
const Color kTextColor = Color(0xFF333333);
const Color kSubTextColor = Color(0xFF666666);

class EditProfileScreen extends StatefulWidget {
  final User currentUser; // Pass the current user data to pre-fill the form

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.currentUser.fullName,
    );
    _emailController = TextEditingController(text: widget.currentUser.email);
    _phoneNumberController = TextEditingController(
      text: widget.currentUser.phoneNumber,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    setState(() {
      _isLoading = true;
    });

    final token = await StorageService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy token. Vui lòng đăng nhập lại.'),
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      // Call the NEW API service method from ApiUserService
      final updatedUser = await ApiUserService.updateMyProfile(
        // Changed from ApiService.updateProfile
        {
          'fullName': _fullNameController.text,
          'phoneNumber': _phoneNumberController.text,
        },
      );

      // After successful update, save the updated user to local storage
      await StorageService.saveUser(updatedUser);

      if (mounted) {
        // Pass the updated user back to the previous screen (ProfileScreen)
        Navigator.of(context).pop(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật hồ sơ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // For back button color
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              )
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        labelText: 'Họ và tên',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Email field is for display only, cannot be edited here as per typical API design
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Make email field uneditable
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneNumberController,
                        labelText: 'Số điện thoại',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                            return 'Vui lòng nhập số điện thoại hợp lệ (10-11 số)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true, // Added enabled property
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled, // Apply enabled property
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: kSubTextColor),
        floatingLabelStyle: const TextStyle(color: kPrimaryColor),
      ),
      validator: validator,
      style: TextStyle(
        color: enabled ? kTextColor : kSubTextColor.withOpacity(0.7),
      ), // Adjust text color for disabled
    );
  }
}
