import 'package:barber_app/screens/booking/select_salon_screen.dart';
import 'package:barber_app/screens/booking/select_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';
import 'package:barber_app/models/salon.dart';
import 'package:barber_app/models/service.dart';
import 'package:intl/intl.dart'; // Thêm để định dạng ngày và giờ

// Import các màn hình mới (chưa có sẵn, sẽ tạo sau)
import 'package:barber_app/screens/booking/select_stylist_screen.dart';
import 'package:barber_app/screens/booking/ai_cut_recommendation_screen.dart';
import 'package:barber_app/models/stylist.dart'; // Import model stylist

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int currentStep = 0;
  Salon? selectedSalon;
  List<Service> selectedServices = [];
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  Stylist? selectedStylist; // Thêm biến cho stylist được chọn

  List<String> availableTimeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ]; // Giả lập các khung giờ có sẵn

  void _navigateToSelectSalonScreen() async {
    final result = await Navigator.push<Salon>(
      context,
      MaterialPageRoute(builder: (context) => const SelectSalonScreen()),
    );

    if (result != null) {
      setState(() {
        selectedSalon = result;
      });
    }
  }

  void _navigateToSelectServiceScreen() async {
    final result = await Navigator.push<List<Service>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectServiceScreen(
              initialSelectedServices:
                  selectedServices, // Truyền dịch vụ đã chọn để hiển thị
            ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedServices = result;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryDarkBlue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.primaryDarkBlue, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDarkBlue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _navigateToSelectStylistScreen() async {
    final result = await Navigator.push<Stylist>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectStylistScreen(
              // Truyền salon đã chọn để lọc stylist (tùy chọn)
              salonId: selectedSalon!.id.toString(),
            ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedStylist = result;
      });
    }
  }

  void _navigateToAICutRecommendationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AICutRecommendationScreen(),
      ),
    );
  }

  String _formatServices(List<Service> services) {
    if (services.isEmpty) return 'Chưa chọn dịch vụ nào';
    return services.map((s) => s.name).join(', ');
  }

  double get _totalPrice {
    return selectedServices.fold(0.0, (sum, service) => sum + service.price);
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkBlue,
        title: const Text(
          'Đặt lịch gội cắt',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepTapped: (step) => setState(() => currentStep = step),
        onStepContinue: () {
          if (currentStep == 0 && selectedSalon == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng chọn salon trước khi tiếp tục.'),
              ),
            );
          } else if (currentStep == 1 && selectedServices.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng chọn dịch vụ trước khi tiếp tục.'),
              ),
            );
          } else if (currentStep == 2 && selectedTimeSlot == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng chọn giờ cắt trước khi xác nhận.'),
              ),
            );
          } else if (currentStep < 2) {
            setState(() => currentStep += 1);
          } else {
            // Logic khi hoàn thành tất cả các bước
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đặt lịch thành công tại ${selectedSalon!.name} vào ${DateFormat('dd/MM/yyyy').format(selectedDate)} lúc $selectedTimeSlot cho các dịch vụ: ${_formatServices(selectedServices)}' +
                      (selectedStylist != null
                          ? ' với stylist ${selectedStylist!.name}'
                          : ''),
                ),
              ),
            );
            // Có thể thêm Navigator.pop(context) hoặc chuyển đến màn hình xác nhận
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                if (currentStep < 2)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tiếp tục'),
                  ),
                if (currentStep == 2)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Xác nhận đặt lịch'),
                  ),
                const SizedBox(width: 10),
                if (currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryGrey,
                    ),
                    child: const Text('Quay lại'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Chọn salon'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _navigateToSelectSalonScreen,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.store,
                          color:
                              selectedSalon != null
                                  ? AppColors.primaryDarkBlue
                                  : AppColors.secondaryGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedSalon?.name ?? 'Nhấn để chọn salon',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  selectedSalon != null
                                      ? AppColors.primaryDarkBlue
                                      : AppColors.secondaryGrey,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.secondaryGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedSalon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Text(
                      selectedSalon!.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryGrey,
                      ),
                    ),
                  ),
                // Loại bỏ phần "Tìm salon gần tôi"
                // const SizedBox(height: 16),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text(
                //             'Tính năng tìm salon gần đây đang được phát triển!',
                //           ),
                //         ),
                //       );
                //     },
                //     icon: const Icon(Icons.location_on, size: 18),
                //     label: const Text(
                //       'Tìm salon gần tôi',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.accentGreen,
                //       foregroundColor: AppColors.secondaryWhite,
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            isActive: currentStep >= 0,
            state:
                currentStep > 0
                    ? (selectedSalon != null
                        ? StepState.complete
                        : StepState.error)
                    : StepState.indexed,
          ),
          Step(
            title: const Text('Chọn dịch vụ'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _navigateToSelectServiceScreen,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.content_cut,
                          color:
                              selectedServices.isNotEmpty
                                  ? AppColors.primaryDarkBlue
                                  : AppColors.secondaryGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatServices(selectedServices),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  selectedServices.isNotEmpty
                                      ? AppColors.primaryDarkBlue
                                      : AppColors.secondaryGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.secondaryGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedServices.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Tổng tiền dịch vụ: ${_formatCurrency(_totalPrice)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ],
            ),
            isActive: currentStep >= 1,
            state:
                currentStep > 1
                    ? (selectedServices.isNotEmpty
                        ? StepState.complete
                        : StepState.error)
                    : StepState.indexed,
          ),
          Step(
            title: const Text('Chọn ngày, giờ & stylist'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryDarkBlue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.secondaryGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                // Time Slot Selection
                const SizedBox(height: 10),
                const Text(
                  'Chọn giờ cắt:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Để GridView không cuộn độc lập
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 2.5, // Tỷ lệ khung hình của mỗi ô giờ
                  ),
                  itemCount: availableTimeSlots.length,
                  itemBuilder: (context, index) {
                    final time = availableTimeSlots[index];
                    final isSelected = selectedTimeSlot == time;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTimeSlot = time;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.accentBlue
                                  : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.accentBlue
                                    : AppColors.secondaryGrey.withOpacity(0.5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          time,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.primaryDarkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Stylist selection
                const Text(
                  'Chọn Stylist (Tùy chọn):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap:
                      _navigateToSelectStylistScreen, // Điều hướng đến màn hình chọn stylist
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color:
                              selectedStylist != null
                                  ? AppColors.primaryDarkBlue
                                  : AppColors.secondaryGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedStylist?.name ?? 'Chọn stylist yêu thích',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  selectedStylist != null
                                      ? AppColors.primaryDarkBlue
                                      : AppColors.secondaryGrey,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.secondaryGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nút tích hợp AI
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _navigateToAICutRecommendationScreen, // Điều hướng đến màn hình gợi ý AI
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text(
                      'Gợi ý kiểu tóc bằng AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue, // Màu xanh cho AI
                      foregroundColor: AppColors.secondaryWhite,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            isActive: currentStep >= 2,
            state:
                currentStep > 2
                    ? (selectedTimeSlot != null
                        ? StepState.complete
                        : StepState.error)
                    : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
