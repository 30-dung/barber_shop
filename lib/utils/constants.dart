import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      // Địa chỉ backend cho web (có thể là localhost hoặc IP LAN)
      return 'http://192.168.1.32:9090';
    } else if (Platform.isAndroid) {
      // Nếu chạy trên Android emulator, dùng 10.0.2.2
      return 'http://10.0.2.2:9090';
    } else {
      // iOS, Windows, Mac, Linux...
      return 'http://192.168.1.32:9090';
    }
  }
}
