import 'package:flutter/foundation.dart';

import '../../../authentication/domain/entities/app_user.dart';

@immutable
class Report {
  const Report({
    required this.id,
    required this.listingId,
    required this.reporterId,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String reporterId;
  final String reason;
  final String details;

  /// `open`, `dismissed`, `actioned`.
  final String status;
  final DateTime createdAt;
}

@immutable
class AdminUserSummary {
  const AdminUserSummary({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final AccountStatus status;
}

@immutable
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.actorId,
    required this.action,
    required this.targetId,
    required this.createdAt,
  });

  final String id;
  final String actorId;
  final String action;
  final String targetId;
  final DateTime createdAt;
}

@immutable
class AdminStats {
  const AdminStats({
    required this.users,
    required this.pendingListings,
    required this.publishedListings,
    required this.openReports,
  });

  final int users;
  final int pendingListings;
  final int publishedListings;
  final int openReports;
}
