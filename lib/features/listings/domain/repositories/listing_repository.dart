import 'package:flutter/foundation.dart';

import '../entities/listing.dart';

/// Opaque page of results with a cursor for the next page.
@immutable
class ListingPage {
  const ListingPage({required this.items, this.cursor, this.hasMore = false});

  static const empty = ListingPage(items: []);

  final List<Listing> items;

  /// Implementation-specific; pass back unchanged to fetch the next page.
  final Object? cursor;
  final bool hasMore;
}

abstract interface class ListingRepository {
  /// Reserves a new listing id (used for storage paths before creation).
  String newId();

  Future<Listing?> getById(String id);

  /// Creates a listing. Server rules force a review status.
  Future<void> create(Listing listing);

  /// Updates owner-editable content fields.
  Future<void> update(Listing listing);

  /// Owner status change (pause, sold, archive/soft-delete, resubmit).
  Future<void> setOwnerStatus(String id, ListingStatus status);

  Future<ListingPage> getByOwner(
    String ownerId, {
    ListingStatus? status,
    Object? cursor,
    int limit = 20,
  });

  Future<List<Listing>> getRelated(Listing listing, {int limit = 6});

  Future<Map<ListingStatus, int>> countByStatus(String ownerId);
}
