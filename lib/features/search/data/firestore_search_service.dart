import 'package:cloud_firestore/cloud_firestore.dart';

import '../../listings/data/models/listing_mapper.dart';
import '../../listings/domain/entities/listing.dart';
import '../../listings/domain/repositories/listing_repository.dart';
import '../domain/keyword_tokenizer.dart';
import '../domain/query_matcher.dart';
import '../domain/search_query.dart';

/// Firestore search: equality filters + one keyword token (array-contains)
/// server-side; price range for date sorts and extra tokens are refined
/// client-side, refilling up to [_maxFetches] batches to fill a page.
class FirestoreSearchService implements ListingSearchService {
  FirestoreSearchService(this._db);

  static const int _maxFetches = 5;
  final FirebaseFirestore _db;

  @override
  Future<ListingPage> search(
    SearchQuery query, {
    Object? cursor,
    int limit = 20,
  }) async {
    final items = <Listing>[];
    var current = cursor;
    var hasMore = true;
    for (var i = 0; i < _maxFetches && items.length < limit && hasMore; i++) {
      final snap = await _buildQuery(query, current, limit).get();
      hasMore = snap.docs.length == limit;
      if (snap.docs.isNotEmpty) current = snap.docs.last;
      for (final doc in snap.docs) {
        final l = ListingMapper.fromDoc(doc);
        if (_refine(l, doc.data(), query)) items.add(l);
      }
    }
    return ListingPage(items: items, cursor: current, hasMore: hasMore);
  }

  Query<Map<String, dynamic>> _buildQuery(
    SearchQuery q,
    Object? cursor,
    int limit,
  ) {
    Query<Map<String, dynamic>> r = _db
        .collection('listings')
        .where('status', isEqualTo: ListingStatus.published.value);
    if (q.categoryId != null) {
      r = r.where('categoryId', isEqualTo: q.categoryId);
    }
    if (q.subcategoryId != null) {
      r = r.where('subcategoryId', isEqualTo: q.subcategoryId);
    }
    if (q.locationId != null) {
      r = r.where('locationId', isEqualTo: q.locationId);
    }
    if (q.featuredOnly) r = r.where('isFeatured', isEqualTo: true);
    final tokens = KeywordTokenizer.tokens(q.keyword);
    if (tokens.isNotEmpty) {
      r = r.where('searchKeywords', arrayContains: tokens.first);
    }

    switch (q.sort) {
      case SortOption.newest:
        r = r.orderBy('createdAt', descending: true);
      case SortOption.oldest:
        r = r.orderBy('createdAt');
      case SortOption.priceLow:
        r = _priceRange(r, q).orderBy('price');
      case SortOption.priceHigh:
        r = _priceRange(r, q).orderBy('price', descending: true);
    }
    r = r.limit(limit);
    if (cursor is DocumentSnapshot) r = r.startAfterDocument(cursor);
    return r;
  }

  Query<Map<String, dynamic>> _priceRange(
    Query<Map<String, dynamic>> r,
    SearchQuery q,
  ) {
    if (q.minPrice != null) {
      r = r.where('price', isGreaterThanOrEqualTo: q.minPrice);
    }
    if (q.maxPrice != null) {
      r = r.where('price', isLessThanOrEqualTo: q.maxPrice);
    }
    return r;
  }

  bool _refine(Listing l, Map<String, dynamic> data, SearchQuery q) {
    final priceSorted =
        q.sort == SortOption.priceLow || q.sort == SortOption.priceHigh;
    if (!priceSorted && !QueryMatcher.matchesPrice(l, q)) return false;
    final tokens = KeywordTokenizer.tokens(q.keyword);
    if (tokens.length > 1) {
      final stored = List<String>.from(
        (data['searchKeywords'] ?? const <String>[]) as List,
      );
      if (!tokens.every(stored.contains)) return false;
    }
    return true;
  }
}
