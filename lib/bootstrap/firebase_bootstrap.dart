import 'package:firebase_core/firebase_core.dart';

import '../core/logging/app_logger.dart';

/// Outcome of Firebase initialization.
enum FirebaseStatus { initialized, notConfigured, failed }

/// Initializes Firebase from compile-time `--dart-define` values so no
/// credentials are committed. If values are missing, the app still starts
/// and reports [FirebaseStatus.notConfigured] (no fake connection is made).
abstract final class FirebaseBootstrap {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _senderId.isNotEmpty &&
      _projectId.isNotEmpty;

  static Future<FirebaseStatus> initialize() async {
    if (!isConfigured) {
      AppLogger.info(
        'Firebase configuration missing; skipping initialization.',
      );
      return FirebaseStatus.notConfigured;
    }
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: _apiKey,
          appId: _appId,
          messagingSenderId: _senderId,
          projectId: _projectId,
          authDomain: _authDomain.isEmpty ? null : _authDomain,
          storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
        ),
      );
      return FirebaseStatus.initialized;
    } catch (e, st) {
      AppLogger.error('Firebase initialization failed', e, st);
      return FirebaseStatus.failed;
    }
  }
}
