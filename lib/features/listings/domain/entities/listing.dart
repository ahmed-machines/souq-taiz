import 'package:flutter/foundation.dart';

enum ListingStatus {
  draft('draft'),
  pendingReview('pending_review'),
  published('published'),
  rejected('rejected'),
  paused('paused'),
  sold('sold'),
  archived('archived');

  const ListingStatus(this.value);

  /// Value stored in Firestore.
  final String value;

  static ListingStatus parse(String? value) => ListingStatus.values.firstWhere(
    (s) => s.value == value,
    orElse: () => ListingStatus.draft,
  );
}

enum PriceType {
  fixed('fixed'),
  negotiable('negotiable');

  const PriceType(this.value);
  final String value;

  static PriceType parse(String? value) => PriceType.values.firstWhere(
    (s) => s.value == value,
    orElse: () => PriceType.fixed,
  );
}

/// A marketplace advertisement.
@immutable
class Listing {
  const Listing({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.locationId,
    required this.price,
    required this.priceType,
    required this.imageUrls,
    required this.contactPhone,
    required this.status,
    required this.createdAt,
    this.subcategoryId,
    this.currency = 'YER',
    this.isFeatured = false,
    this.rejectionReason,
    this.updatedAt,
    this.viewCount = 0,
  });

  final String id;
  final String ownerId;

  /// Denormalized public display name of the seller.
  final String ownerName;
  final String title;
  final String description;
  final String categoryId;
  final String? subcategoryId;
  final String locationId;
  final num price;
  final String currency;
  final PriceType priceType;

  /// Ordered image URLs; the first is the cover image. Bounded by
  /// `Validators.maxImages`.
  final List<String> imageUrls;
  final String contactPhone;
  final ListingStatus status;
  final bool isFeatured;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Server-owned counter; not shown until reliable tracking exists.
  final int viewCount;

  String? get coverImageUrl => imageUrls.isEmpty ? null : imageUrls.first;
  bool get isPublic => status == ListingStatus.published;
}
