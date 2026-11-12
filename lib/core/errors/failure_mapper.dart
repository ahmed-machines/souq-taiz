import 'package:firebase_auth/firebase_auth.dart';

import '../logging/app_logger.dart';
import 'failure.dart';

/// Converts SDK exceptions into typed [Failure]s. Raw messages are logged,
/// never shown to users.
abstract final class FailureMapper {
  static Failure from(Object error, [StackTrace? stackTrace]) {
    AppLogger.error('Operation failed', error, stackTrace);
    if (error is FirebaseAuthException) {
      return Failure(_auth(error.code), debugMessage: error.code);
    }
    if (error is FirebaseException) {
      return Failure(_firestore(error.code), debugMessage: error.code);
    }
    return Failure(
      FailureType.unknown,
      debugMessage: error.runtimeType.toString(),
    );
  }

  static FailureType _auth(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-email' => FailureType.invalidCredentials,
    'email-already-in-use' => FailureType.emailInUse,
    'weak-password' => FailureType.weakPassword,
    'user-disabled' => FailureType.accountSuspended,
    'too-many-requests' => FailureType.tooManyRequests,
    'network-request-failed' => FailureType.network,
    'popup-closed-by-user' ||
    'cancelled-popup-request' => FailureType.cancelled,
    _ => FailureType.unknown,
  };

  static FailureType _firestore(String code) => switch (code) {
    'permission-denied' => FailureType.permissionDenied,
    'unauthenticated' => FailureType.unauthenticated,
    'not-found' => FailureType.notFound,
    'unavailable' || 'deadline-exceeded' => FailureType.network,
    _ => FailureType.unknown,
  };
}
