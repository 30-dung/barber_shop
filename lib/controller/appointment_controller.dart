// controllers/appointment_controller.dart
import 'package:barber_app/models/appointment.dart';
import 'package:barber_app/services/api_service.dart'; // Sửa lại import
import 'package:flutter/material.dart';

class AppointmentController with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointments =
          await ApiService().getAppointments(); // Sử dụng ApiService
      _appointments = appointments;
      print('Appointments fetched: ${appointments.length}'); // Debug
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching appointments: $e'); // Debug lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
