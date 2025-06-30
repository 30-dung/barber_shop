import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shine_booking_app/models/appointment_model.dart';
import 'package:shine_booking_app/services/api_appointments.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> _userAppointments = [];
  List<Appointment> _employeeAppointments = [];
  bool _isLoadingUser = true;
  bool _isLoadingEmployee = true;
  String? _error;
  String _employeeEmail = ''; // Có thể lấy từ user profile hoặc input

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserAppointments();
    // Uncomment và set email để load employee appointments
    // _loadEmployeeAppointments('employee@example.com');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAppointments() async {
    try {
      setState(() {
        _isLoadingUser = true;
        _error = null;
      });

      final appointments = await ApiAppointmentsService.getUserBookings();
      setState(() {
        _userAppointments = appointments;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadEmployeeAppointments(String email) async {
    try {
      setState(() {
        _isLoadingEmployee = true;
        _error = null;
      });

      final appointments =
          await ApiAppointmentsService.getAppointmentsByEmployeeEmail(email);
      setState(() {
        _employeeAppointments = appointments;
        _isLoadingEmployee = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingEmployee = false;
      });
    }
  }

  Future<void> _confirmAppointment(
    int appointmentId,
    int listIndex,
    bool isUserTab,
  ) async {
    try {
      await ApiAppointmentsService.confirmAppointment(appointmentId);

      setState(() {
        if (isUserTab) {
          _userAppointments[listIndex] = _userAppointments[listIndex].copyWith(
            status: Status.CONFIRMED,
          );
        } else {
          _employeeAppointments[listIndex] = _employeeAppointments[listIndex]
              .copyWith(status: Status.CONFIRMED);
        }
      });

      _showSuccessSnackBar('Cuộc hẹn đã được xác nhận');
    } catch (e) {
      _showErrorSnackBar('Lỗi xác nhận cuộc hẹn: $e');
    }
  }

  Future<void> _completeAppointment(
    int appointmentId,
    int listIndex,
    bool isUserTab,
  ) async {
    try {
      await ApiAppointmentsService.completeAppointment(appointmentId);

      setState(() {
        if (isUserTab) {
          _userAppointments[listIndex] = _userAppointments[listIndex].copyWith(
            status: Status.COMPLETED,
            completedAt: DateTime.now(),
          );
        } else {
          _employeeAppointments[listIndex] = _employeeAppointments[listIndex]
              .copyWith(status: Status.COMPLETED, completedAt: DateTime.now());
        }
      });

      _showSuccessSnackBar('Cuộc hẹn đã hoàn thành');
    } catch (e) {
      _showErrorSnackBar('Lỗi hoàn thành cuộc hẹn: $e');
    }
  }

  Future<void> _cancelAppointment(
    int appointmentId,
    int listIndex,
    bool isUserTab,
  ) async {
    final confirmed = await _showConfirmDialog(
      'Hủy cuộc hẹn',
      'Bạn có chắc chắn muốn hủy cuộc hẹn này?',
    );

    if (!confirmed) return;

    try {
      await ApiAppointmentsService.cancelAppointment(appointmentId);

      setState(() {
        if (isUserTab) {
          _userAppointments[listIndex] = _userAppointments[listIndex].copyWith(
            status: Status.CANCELED,
          );
        } else {
          _employeeAppointments[listIndex] = _employeeAppointments[listIndex]
              .copyWith(status: Status.CANCELED);
        }
      });

      _showSuccessSnackBar('Cuộc hẹn đã được hủy');
    } catch (e) {
      _showErrorSnackBar('Lỗi hủy cuộc hẹn: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.PENDING:
        return Colors.orange;
      case Status.CONFIRMED:
        return Colors.blue;
      case Status.COMPLETED:
        return Colors.green;
      case Status.CANCELED:
        return Colors.red;
    }
  }

  String _getStatusText(Status status) {
    switch (status) {
      case Status.PENDING:
        return 'Chờ xác nhận';
      case Status.CONFIRMED:
        return 'Đã xác nhận';
      case Status.COMPLETED:
        return 'Hoàn thành';
      case Status.CANCELED:
        return 'Đã hủy';
    }
  }

  List<Widget> _getActionButtons(
    Appointment appointment,
    int index,
    bool isUserTab,
  ) {
    List<Widget> buttons = [];

    switch (appointment.status) {
      case Status.PENDING:
        buttons.addAll([
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed:
                () => _confirmAppointment(
                  appointment.appointmentId,
                  index,
                  isUserTab,
                ),
            tooltip: 'Xác nhận',
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed:
                () => _cancelAppointment(
                  appointment.appointmentId,
                  index,
                  isUserTab,
                ),
            tooltip: 'Hủy',
          ),
        ]);
        break;
      case Status.CONFIRMED:
        buttons.addAll([
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blue),
            onPressed:
                () => _completeAppointment(
                  appointment.appointmentId,
                  index,
                  isUserTab,
                ),
            tooltip: 'Hoàn thành',
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed:
                () => _cancelAppointment(
                  appointment.appointmentId,
                  index,
                  isUserTab,
                ),
            tooltip: 'Hủy',
          ),
        ]);
        break;
      case Status.COMPLETED:
      case Status.CANCELED:
        // Không có action cho trạng thái đã hoàn thành hoặc đã hủy
        break;
    }

    return buttons;
  }

  Widget _buildAppointmentCard(
    Appointment appointment,
    int index,
    bool isUserTab,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(appointment.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  appointment.slug,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thông tin dịch vụ
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${appointment.storeService.storeName} - ${appointment.storeService.serviceName}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thông tin nhân viên
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('NV: ${appointment.employee.fullName}'),
              ],
            ),
            const SizedBox(height: 8),

            // Thông tin khách hàng
            Row(
              children: [
                const Icon(Icons.account_circle, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text('KH: ${appointment.user.fullName}')),
              ],
            ),
            const SizedBox(height: 8),

            // Thời gian
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
                ),
              ],
            ),

            // Tổng tiền (nếu có)
            if (appointment.invoice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payments, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(appointment.invoice!.totalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            // Ghi chú (nếu có)
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ghi chú: ${appointment.notes}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],

            // Actions
            if (_getActionButtons(
              appointment,
              index,
              isUserTab,
            ).isNotEmpty) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _getActionButtons(appointment, index, isUserTab),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<Appointment> appointments,
    bool isLoading,
    bool isUserTab,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  isUserTab
                      ? _loadUserAppointments
                      : () => _loadEmployeeAppointments(_employeeEmail),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isUserTab
                  ? 'Không có cuộc hẹn nào'
                  : 'Không có cuộc hẹn cho nhân viên này',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          isUserTab
              ? _loadUserAppointments
              : () => _loadEmployeeAppointments(_employeeEmail),
      child: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index], index, isUserTab);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý cuộc hẹn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Cuộc hẹn của tôi'),
            Tab(icon: Icon(Icons.work), text: 'Quản lý nhân viên'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                _loadUserAppointments();
              } else {
                if (_employeeEmail.isNotEmpty) {
                  _loadEmployeeAppointments(_employeeEmail);
                }
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab cuộc hẹn của user
          _buildAppointmentsList(_userAppointments, _isLoadingUser, true),

          // Tab quản lý nhân viên
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email nhân viên',
                    hintText: 'Nhập email nhân viên để xem cuộc hẹn',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _employeeEmail = value;
                      });
                      _loadEmployeeAppointments(value);
                    }
                  },
                ),
              ),
              Expanded(
                child: _buildAppointmentsList(
                  _employeeAppointments,
                  _isLoadingEmployee,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
