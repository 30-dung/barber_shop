// booking_datetime_screen.dart
import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import '../../models/employee_model.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import '../../models/working_time_slot_model.dart';
import '../../models/store_service_model.dart'; // Import this
import 'appointment_confirmation_screen.dart'; // Import this

class AppointmentDateTimeScreen extends StatefulWidget {
  final Store store;
  final StoreService storeService; // Changed from ServiceDetail to StoreService
  final Employee employee;

  const AppointmentDateTimeScreen({
    super.key,
    required this.store,
    required this.storeService, // Update required field
    required this.employee,
  });

  @override
  State<AppointmentDateTimeScreen> createState() =>
      _AppointmentDateTimeScreenState();
}

class _AppointmentDateTimeScreenState extends State<AppointmentDateTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  WorkingTimeSlot? _selectedTimeSlot;
  List<WorkingTimeSlot> _availableTimeSlots = [];
  bool _isLoadingTimeSlots = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableTimeSlots();
  }

  Future<void> _loadAvailableTimeSlots() async {
    setState(() {
      _isLoadingTimeSlots = true;
      _availableTimeSlots = [];
      _selectedTimeSlot = null;
    });
    try {
      // getAvailableTimeSlots từ API sẽ chỉ trả về các khung giờ khả dụng dựa trên logic backend.
      final slots = await ApiService.getAvailableTimeSlots(
        storeId: widget.store.storeId!,
        serviceId:
            widget
                .storeService
                .service
                .serviceId, // Sử dụng serviceId từ storeService
        employeeId: widget.employee.employeeId!,
        date: _selectedDate,
      );
      setState(() {
        // Backend nên tự động lọc các khung giờ có sẵn.
        // Chúng ta lọc rõ ràng ở đây một lần nữa để an toàn, nhưng lý tưởng là backend xử lý nó.
        _availableTimeSlots =
            slots.where((slot) => slot.isAvailable == true).toList();
        _isLoadingTimeSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingTimeSlots = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải giờ trống: $e')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailableTimeSlots();
    }
  }

  void _goToConfirmationScreen() {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một giờ hẹn.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AppointmentConfirmationScreen(
              storeService: widget.storeService,
              store: widget.store,
              employee: widget.employee,
              slot: _selectedTimeSlot!,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Ngày & Giờ Hẹn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cửa hàng: ${widget.store.storeName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dịch vụ: ${widget.storeService.service.serviceName}', // Sử dụng serviceName từ storeService
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhân viên: ${widget.employee.fullName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Chọn ngày:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn giờ:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isLoadingTimeSlots
                ? const Center(child: CircularProgressIndicator())
                : _availableTimeSlots.isEmpty
                ? const Center(child: Text('Không có giờ trống cho ngày này.'))
                : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: _availableTimeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _availableTimeSlots[index];
                      final displayTime = DateFormat('HH:mm').format(
                        DateTime.parse(
                          (slot.startTime ?? DateTime.now().toIso8601String())
                              .toString(),
                        ),
                      );
                      final isSelected =
                          _selectedTimeSlot?.timeSlotId == slot.timeSlotId &&
                          _selectedTimeSlot?.startTime == slot.startTime;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFFFF6B35)
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFFFF6B35)
                                      : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            displayTime,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedTimeSlot == null ? null : _goToConfirmationScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tiếp tục', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
