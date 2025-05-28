import 'package:barber_app/screens/booking/select_salon_screen.dart';
import 'package:barber_app/screens/booking/select_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';
import 'package:barber_app/models/salon.dart';
import 'package:barber_app/models/service.dart';
import 'package:intl/intl.dart';

// Import các màn hình mới (chưa có sẵn, sẽ tạo sau)
import 'package:barber_app/screens/booking/select_stylist_screen.dart';
import 'package:barber_app/screens/booking/ai_cut_recommendation_screen.dart';
import 'package:barber_app/models/stylist.dart'; // Import model stylist

class ReserveScreen extends StatefulWidget {
  const ReserveScreen({Key? key}) : super(key: key);

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  Salon? selectedSalon;
  List<Service> selectedServices = [];
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  Stylist? selectedStylist; // Để chứa stylist được chọn (nếu có)

  final List<String> _availableTimeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
  ];

  Future<void> _navigateToSelectSalonScreen() async {
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

  Future<void> _navigateToSelectServiceScreen() async {
    final result = await Navigator.push<List<Service>>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SelectServiceScreen(initialSelectedServices: selectedServices),
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
              primary: AppColors.primaryDarkBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryDarkBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDarkBlue,
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
            (context) =>
                SelectStylistScreen(salonId: selectedSalon!.id.toString()),
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

  bool get _isBookingReady {
    return selectedSalon != null &&
        selectedServices.isNotEmpty &&
        selectedTimeSlot != null;
  }

  void _confirmBooking() {
    if (!_isBookingReady) {
      String message = 'Vui lòng điền đầy đủ thông tin:';
      if (selectedSalon == null) message += '\n- Chọn salon';
      if (selectedServices.isEmpty) message += '\n- Chọn dịch vụ';
      if (selectedTimeSlot == null) message += '\n- Chọn ngày & giờ cắt';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã đặt lịch tại ${selectedSalon!.name} vào ${DateFormat('dd/MM/yyyy').format(selectedDate)} lúc $selectedTimeSlot cho các dịch vụ: ${_formatServices(selectedServices)}. Tổng tiền: ${_formatCurrency(_totalPrice)}' +
              (selectedStylist != null
                  ? ' với stylist ${selectedStylist!.name}'
                  : ''),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
    // Add navigation logic or API call here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đặt lịch giữ chỗ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.secondaryWhite,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.secondaryWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1 - Chọn salon
            _buildStepHeader(1, 'Chọn salon', selectedSalon != null),
            const SizedBox(height: 16),
            _buildSelectionContainer(
              icon: Icons.home,
              title: selectedSalon?.name ?? 'Xem tất cả salon',
              subtitle: selectedSalon?.address,
              onTap: _navigateToSelectSalonScreen,
              borderColor:
                  selectedSalon == null
                      ? Colors.red.shade300
                      : AppColors.secondaryGrey.withOpacity(0.5),
              backgroundColor:
                  selectedSalon == null
                      ? Colors.red.shade50
                      : AppColors.secondaryWhite,
              iconColor:
                  selectedSalon == null
                      ? Colors.red
                      : AppColors.secondaryGrey.withOpacity(0.7),
              showWarning: selectedSalon == null,
              warningText:
                  'Anh vui lòng chọn salon trước để xem lịch còn trống a!',
            ),

            // Loại bỏ phần "Tìm salon gần anh"
            // const SizedBox(height: 16),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text(
            //             'Tính năng tìm salon gần tôi đang được phát triển!',
            //           ),
            //         ),
            //       );
            //     },
            //     icon: const Icon(Icons.location_on, size: 18),
            //     label: const Text(
            //       'Tìm salon gần anh',
            //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            const SizedBox(height: 32),

            // Step 2 - Chọn dịch vụ
            _buildStepHeader(2, 'Chọn dịch vụ', selectedServices.isNotEmpty),
            const SizedBox(height: 16),
            _buildSelectionContainer(
              icon: Icons.content_cut,
              title: _formatServices(selectedServices),
              onTap: _navigateToSelectServiceScreen,
              borderColor:
                  selectedServices.isEmpty
                      ? Colors.red.shade300
                      : AppColors.secondaryGrey.withOpacity(0.5),
              backgroundColor:
                  selectedServices.isEmpty
                      ? Colors.red.shade50
                      : AppColors.secondaryWhite,
              iconColor:
                  selectedServices.isEmpty
                      ? Colors.red
                      : AppColors.secondaryGrey.withOpacity(0.7),
              showWarning: selectedServices.isEmpty,
              warningText: 'Vui lòng chọn ít nhất một dịch vụ để tiếp tục.',
              trailingWidget:
                  selectedServices.isNotEmpty
                      ? Text(
                        _formatCurrency(_totalPrice),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentBlue,
                        ),
                      )
                      : null,
            ),

            const SizedBox(height: 32),

            // Step 3 - Chọn ngày, giờ & stylist
            _buildStepHeader(
              3,
              'Chọn ngày, giờ & stylist',
              selectedTimeSlot != null,
            ),
            const SizedBox(height: 16),
            // Date Selection
            _buildSelectionContainer(
              icon: Icons.calendar_today,
              title:
                  'Ngày: ${DateFormat('dd/MM/yyyy (E)').format(selectedDate)}',
              onTap: () => _selectDate(context),
              borderColor: AppColors.secondaryGrey.withOpacity(0.5),
              backgroundColor: AppColors.secondaryWhite,
              iconColor: AppColors.secondaryGrey.withOpacity(0.7),
              trailingWidget: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Ngày thường', // Could be dynamic
                  style: TextStyle(
                    color: AppColors.secondaryWhite,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time Slot Selection
            const Text(
              'Chọn giờ cắt:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 2.2,
              ),
              itemCount: _availableTimeSlots.length,
              itemBuilder: (context, index) {
                final time = _availableTimeSlots[index];
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
                              : AppColors.secondaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.accentBlue
                                : AppColors.lightGrey,
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
            const SizedBox(height: 16),
            // Stylist selection
            _buildSelectionContainer(
              icon: Icons.person,
              title: selectedStylist?.name ?? 'Chọn stylist yêu thích',
              onTap:
                  _navigateToSelectStylistScreen, // Điều hướng đến màn hình chọn stylist
              borderColor: AppColors.secondaryGrey.withOpacity(0.5),
              backgroundColor: AppColors.secondaryWhite,
              iconColor: AppColors.secondaryGrey.withOpacity(0.7),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

            const SizedBox(height: 40),

            // Bottom booking confirmation button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    _isBookingReady
                        ? AppColors.primaryDarkBlue
                        : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _isBookingReady ? _confirmBooking : null,
                child: Column(
                  children: [
                    Text(
                      'CHỐT GIỜ CẮT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            _isBookingReady
                                ? AppColors.secondaryWhite
                                : AppColors.secondaryGrey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cắt xong trả tiền, hủy lịch không sao',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            _isBookingReady
                                ? AppColors.secondaryWhite.withOpacity(0.8)
                                : AppColors.secondaryGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget to build step headers
  Widget _buildStepHeader(int stepNumber, String title, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? AppColors.accentBlue
                    : AppColors.secondaryGrey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color:
                    isCompleted
                        ? AppColors.secondaryWhite
                        : AppColors.secondaryGrey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Helper widget to build selection containers
  Widget _buildSelectionContainer({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color borderColor,
    required Color backgroundColor,
    required Color iconColor,
    bool showWarning = false,
    String? warningText,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailingWidget != null) ...[
                  const SizedBox(width: 8),
                  trailingWidget,
                ],
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
            if (showWarning && warningText != null && warningText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  warningText,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
