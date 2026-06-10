import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiEndpoints {
  static String get baseUrl {
    // If running in Web or Desktop
    if (kIsWeb) {
      return "http://localhost:3000/api";
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 is the special IP address mapping to host's localhost in Android emulator
        return "http://10.0.2.2:3000/api";
      }
    } catch (_) {
      // Fallback for platform exception or web environments
    }
    return "http://localhost:3000/api";
  }

  // Endpoints
  static const String login = "auth/login";
  static const String users = "users";
  static const String articles = "articles";
  static const String seminars = "seminars";
  static const String participants = "participants";
  static const String materials = "materials";
  static const String schedules = "schedules";
  static const String regulations = "regulations";
  static const String evaluations = "evaluations";
  static const String galleries = "galleries";
  static const String guides = "guides";
}
