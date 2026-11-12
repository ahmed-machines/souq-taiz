/// Categories of expected failures. UI maps these to localized messages;
/// technical details stay in [Failure.debugMessage] and are only logged.
enum FailureType {
  network,
  unauthenticated,
  permissionDenied,
  notFound,
  validation,
  configuration,
  invalidCredentials,
  emailInUse,
  weakPassword,
  accountSuspended,
  tooManyRequests,
  cancelled,
  unknown,
}

/// Typed, UI-safe description of what went wrong.
class Failure {
  const Failure(this.type, {this.debugMessage});

  final FailureType type;

  /// Technical detail for logs only. Never show directly to users.
  final String? debugMessage;

  @override
  String toString() => 'Failure($type, $debugMessage)';
}
