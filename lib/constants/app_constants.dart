// lib/constants/app_constants.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9090';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:9090';
    } else {
      return 'http://192.168.1.32:9090';
    }
  }

  static const String apiKey = 'your_api_key_here';
  static const int timeoutDuration = 30;
}
