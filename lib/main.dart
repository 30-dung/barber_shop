import 'package:flutter/material.dart';
import 'package:barber_app/config/theme.dart';
import 'package:barber_app/config/routes.dart';
import 'package:barber_app/screens/splash/splash_screen.dart';

void main() {
  runApp(const ThirtyShineApp());
}

class ThirtyShineApp extends StatelessWidget {
  const ThirtyShineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '30Shine',
      theme: appTheme,
      home: const SplashScreen(),
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
