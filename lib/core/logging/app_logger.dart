import 'package:flutter/foundation.dart';

/// Minimal logging facade. Centralised so a crash/monitoring backend
/// (e.g. Crashlytics-like service) can be plugged in later without touching
/// call sites. Never log credentials or personal data.
abstract final class AppLogger {
  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message${error != null ? ' | $error' : ''}');
    if (kDebugMode && stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
