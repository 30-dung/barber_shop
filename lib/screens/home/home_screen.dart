import 'package:flutter/material.dart';
import 'package:barber_app/screens/home/dashboard_screen.dart';
import 'package:barber_app/screens/services/services_screen.dart';
import 'package:barber_app/screens/booking/booking_screen.dart';
import 'package:barber_app/screens/shop/shop_screen.dart';
import 'package:barber_app/screens/profile/profile_screen.dart';
import 'package:barber_app/widgets/common/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ServicesScreen(),
    const BookingScreen(),
    const ShopScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
