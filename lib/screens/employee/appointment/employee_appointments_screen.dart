// lib/screens/employee/employee_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:shine_booking_app/models/appointment_model.dart';
import 'package:shine_booking_app/services/api_appointments.dart'; // Sử dụng API mới
import 'package:shine_booking_app/services/storage_service.dart'; // Để lấy email nhân viên
import 'package:intl/intl.dart'; // For date formatting

class EmployeeAppointmentsScreen extends StatefulWidget {
  const EmployeeAppointmentsScreen({super.key});

  @override
  State<EmployeeAppointmentsScreen> createState() =>
      _EmployeeAppointmentsScreenState();
}

class _EmployeeAppointmentsScreenState extends State<EmployeeAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _employeeEmail;
  Status? _selectedStatusFilter;
  late TabController _tabController;

  // Color palette
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadEmployeeEmailAndAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedStatusFilter = null;
          break;
        case 1:
          _selectedStatusFilter = Status.PENDING;
          break;
        case 2:
          _selectedStatusFilter = Status.CONFIRMED;
          break;
        case 3:
          _selectedStatusFilter = Status.COMPLETED;
          break;
        case 4:
          _selectedStatusFilter = Status.CANCELED;
          break;
      }
      _filterAppointments();
    });
  }

  void _filterAppointments() {
    if (_selectedStatusFilter == null) {
      _filteredAppointments = List.from(_appointments);
    } else {
      _filteredAppointments =
          _appointments
              .where(
                (appointment) => appointment.status == _selectedStatusFilter,
              )
              .toList();
    }

    // Sort by start time
    _filteredAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> _loadEmployeeEmailAndAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final employee = await StorageService.getEmployee();
      if (employee != null && employee.email.isNotEmpty) {
        _employeeEmail = employee.email;
        await _loadAppointments();
      } else {
        _errorMessage =
            'Không tìm thấy email nhân viên. Vui lòng đăng nhập lại.';
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải thông tin nhân viên: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    if (_employeeEmail == null) {
      _errorMessage = 'Email nhân viên không có sẵn để tải cuộc hẹn.';
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _appointments =
          await ApiAppointmentsService.getAppointmentsByEmployeeEmail(
            _employeeEmail!,
          );
      _filterAppointments();
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách cuộc hẹn: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAppointmentStatus(
    int appointmentId,
    Status newStatus,
    String actionText,
  ) async {
    // Show confirmation dialog for important actions
    if (newStatus == Status.CANCELED || newStatus == Status.COMPLETED) {
      final confirmed = await _showConfirmationDialog(
        title: '$actionText cuộc hẹn',
        content:
            'Bạn có chắc chắn muốn ${actionText.toLowerCase()} cuộc hẹn này?',
      );
      if (!confirmed) return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      if (newStatus == Status.CONFIRMED) {
        await ApiAppointmentsService.confirmAppointment(appointmentId);
      } else if (newStatus == Status.COMPLETED) {
        await ApiAppointmentsService.completeAppointment(appointmentId);
      } else if (newStatus == Status.CANCELED) {
        await ApiAppointmentsService.cancelAppointment(appointmentId);
      }
      _showSnackBar('$actionText cuộc hẹn thành công!', isSuccess: true);
      await _loadAppointments();
    } catch (e) {
      _showSnackBar('Lỗi $actionText cuộc hẹn: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline
                    : isSuccess
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor:
              isError
                  ? Colors.red[600]
                  : isSuccess
                  ? Colors.green[600]
                  : Colors.blue[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.PENDING:
        return Colors.orange[700]!;
      case Status.CONFIRMED:
        return Colors.blue[700]!;
      case Status.COMPLETED:
        return Colors.green[700]!;
      case Status.CANCELED:
        return Colors.red[700]!;
    }
  }

  IconData _getStatusIcon(Status status) {
    switch (status) {
      case Status.PENDING:
        return Icons.schedule;
      case Status.CONFIRMED:
        return Icons.check_circle_outline;
      case Status.COMPLETED:
        return Icons.task_alt;
      case Status.CANCELED:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusText(Status status) {
    switch (status) {
      case Status.PENDING:
        return 'Đang chờ';
      case Status.CONFIRMED:
        return 'Đã xác nhận';
      case Status.COMPLETED:
        return 'Đã hoàn thành';
      case Status.CANCELED:
        return 'Đã hủy';
    }
  }

  int _getStatusCount(Status status) {
    return _appointments
        .where((appointment) => appointment.status == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: cardColor,
      foregroundColor: textPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý cuộc hẹn',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: textPrimary,
            ),
          ),
          if (_appointments.isNotEmpty)
            Text(
              '${_appointments.length} cuộc hẹn',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _isLoading ? null : _loadAppointments,
          tooltip: 'Làm mới',
        ),
        const SizedBox(width: 8),
      ],
      bottom: _appointments.isNotEmpty ? _buildTabBar() : null,
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: primaryColor,
      labelColor: primaryColor,
      unselectedLabelColor: textSecondary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      tabs: [
        Tab(child: _buildTabContent('Tất cả', _appointments.length)),
        Tab(
          child: _buildTabContent('Chờ xử lý', _getStatusCount(Status.PENDING)),
        ),
        Tab(
          child: _buildTabContent(
            'Đã xác nhận',
            _getStatusCount(Status.CONFIRMED),
          ),
        ),
        Tab(
          child: _buildTabContent(
            'Hoàn thành',
            _getStatusCount(Status.COMPLETED),
          ),
        ),
        Tab(
          child: _buildTabContent('Đã hủy', _getStatusCount(Status.CANCELED)),
        ),
      ],
    );
  }

  Widget _buildTabContent(String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải cuộc hẹn...', style: TextStyle(color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return _appointments.isEmpty
        ? _buildEmptyState()
        : TabBarView(
          controller: _tabController,
          children: List.generate(5, (index) => _buildAppointmentsList()),
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có cuộc hẹn nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các cuộc hẹn của bạn sẽ hiển thị ở đây',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_filteredAppointments.isEmpty) {
      String emptyMessage =
          _selectedStatusFilter == null
              ? 'Không có cuộc hẹn nào'
              : 'Không có cuộc hẹn ${_getStatusText(_selectedStatusFilter!).toLowerCase()}';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _filteredAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with service name and status
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(appointment.status),
                    color: _getStatusColor(appointment.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.storeService.serviceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        _getStatusText(appointment.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(appointment.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  // HIỂN THỊ SLUG THAY VÌ APPOINTMENT ID
                  appointment.slug,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Customer info
                _buildInfoSection(
                  icon: Icons.person_outline,
                  title: 'Khách hàng',
                  content: appointment.user.fullName,
                  subtitle: appointment.user.phoneNumber ?? 'Chưa cung cấp SĐT',
                ),

                const Divider(height: 24),

                // Time info
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Icons.access_time,
                        label: 'Thời gian',
                        time:
                            '${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}',
                        date: _formatDate(appointment.startTime),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Icons.store_outlined,
                        label: 'Cửa hàng',
                        time: appointment.storeService.storeName,
                        date: 'Đặt lúc ${_formatTime(appointment.createdAt)}',
                      ),
                    ),
                  ],
                ),

                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildInfoSection(
                    icon: Icons.notes_outlined,
                    title: 'Ghi chú',
                    content: appointment.notes!,
                  ),
                ],

                const SizedBox(height: 16),
                _buildActionButtons(appointment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(date, style: TextStyle(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Appointment appointment) {
    if (appointment.status != Status.PENDING &&
        appointment.status != Status.CONFIRMED) {
      return const SizedBox.shrink();
    }

    List<Widget> buttons = [];

    if (appointment.status == Status.PENDING) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : () => _updateAppointmentStatus(
                      appointment.appointmentId,
                      Status.CONFIRMED,
                      'Xác nhận',
                    ),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Xác nhận'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 8));
    }

    if (appointment.status == Status.CONFIRMED) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : () => _updateAppointmentStatus(
                      appointment.appointmentId,
                      Status.COMPLETED,
                      'Hoàn thành',
                    ),
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Hoàn thành'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 8));
    }

    buttons.add(
      Expanded(
        child: OutlinedButton.icon(
          onPressed:
              _isLoading
                  ? null
                  : () => _updateAppointmentStatus(
                    appointment.appointmentId,
                    Status.CANCELED,
                    'Hủy',
                  ),
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Hủy'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red[600],
            side: BorderSide(color: Colors.red[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );

    return Row(children: buttons);
  }
}
