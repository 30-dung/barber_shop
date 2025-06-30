import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this
import 'screens/splash_screen.dart';

void main() async {
  // Change main to async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  // Khởi tạo dữ liệu định dạng ngày tháng cho locale 'vi_VN'
  await initializeDateFormatting('vi_VN', null); // Initialize locale data

  runApp(const ShineBookingApp());
}

class ShineBookingApp extends StatelessWidget {
  const ShineBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '30Shine Booking',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFF6B35),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
