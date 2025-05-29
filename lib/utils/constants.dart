import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// app_constants.dart
class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9090'; // Thử đổi thành localhost cho web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:9090';
    } else {
      return 'http://192.168.1.32:9090';
    }
  }
}
