import 'package:flutter/foundation.dart';

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.listingId,
    this.listingTitle,
    this.reason,
  });

  final String id;

  /// `listing_approved`, `listing_rejected`, `new_message`, `listing_status`,
  /// `account_status`. Text is localized client-side from the type.
  final String type;
  final String? listingId;
  final String? listingTitle;
  final String? reason;
  final DateTime createdAt;
  final bool isRead;
}
