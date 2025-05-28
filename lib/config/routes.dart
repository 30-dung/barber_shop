import 'package:barber_app/screens/home/home_screen.dart';
import 'package:barber_app/screens/auth/login_screen.dart';
import 'package:barber_app/screens/services/services_screen.dart';
import 'package:barber_app/screens/booking/booking_screen.dart';
import 'package:barber_app/screens/profile/profile_screen.dart';
import 'package:barber_app/screens/shop/shop_screen.dart';
import 'package:barber_app/screens/booking/reserve_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/services': (context) => const ServicesScreen(),
  '/booking': (context) => const BookingScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/shop': (context) => const ShopScreen(),
  '/reserve': (context) => const ReserveScreen(),
};
