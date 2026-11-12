import 'package:flutter/foundation.dart';

/// Authorization roles. `guest` is the unauthenticated state.
enum UserRole {
  guest('guest'),
  buyer('buyer'),
  seller('seller'),
  admin('admin'),
  superAdmin('super_admin');

  const UserRole(this.value);
  final String value;

  static UserRole parse(String? v) => UserRole.values.firstWhere(
    (r) => r.value == v,
    orElse: () => UserRole.buyer,
  );

  bool get isAdmin => this == admin || this == superAdmin;
}

enum AccountStatus {
  active('active'),
  suspended('suspended');

  const AccountStatus(this.value);
  final String value;

  static AccountStatus parse(String? v) => AccountStatus.values.firstWhere(
    (s) => s.value == v,
    orElse: () => AccountStatus.active,
  );
}

/// Authenticated user. Role is for UI hints only; enforcement happens in
/// Firestore rules and Cloud Functions.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.emailVerified,
    this.phone,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final AccountStatus status;
  final bool emailVerified;
  final String? phone;

  bool get isActive => status == AccountStatus.active;
  bool get isAdmin => role.isAdmin && isActive;
  bool get canPublish => isActive;
}
