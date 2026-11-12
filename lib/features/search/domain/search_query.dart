import '../../listings/domain/repositories/listing_repository.dart';

enum SortOption { newest, oldest, priceLow, priceHigh }

/// Immutable search criteria.
class SearchQuery {
  const SearchQuery({
    this.keyword = '',
    this.categoryId,
    this.subcategoryId,
    this.locationId,
    this.minPrice,
    this.maxPrice,
    this.featuredOnly = false,
    this.sort = SortOption.newest,
  });

  final String keyword;
  final String? categoryId;
  final String? subcategoryId;
  final String? locationId;
  final num? minPrice;
  final num? maxPrice;
  final bool featuredOnly;
  final SortOption sort;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Copy with explicit nullable overrides via the `clear*` flags.
  SearchQuery copyWith({
    String? keyword,
    String? categoryId,
    bool clearCategory = false,
    String? subcategoryId,
    bool clearSubcategory = false,
    String? locationId,
    bool clearLocation = false,
    num? minPrice,
    bool clearMin = false,
    num? maxPrice,
    bool clearMax = false,
    bool? featuredOnly,
    SortOption? sort,
  }) => SearchQuery(
    keyword: keyword ?? this.keyword,
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    subcategoryId: clearSubcategory || clearCategory
        ? null
        : (subcategoryId ?? this.subcategoryId),
    locationId: clearLocation ? null : (locationId ?? this.locationId),
    minPrice: clearMin ? null : (minPrice ?? this.minPrice),
    maxPrice: clearMax ? null : (maxPrice ?? this.maxPrice),
    featuredOnly: featuredOnly ?? this.featuredOnly,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.keyword == keyword &&
      other.categoryId == categoryId &&
      other.subcategoryId == subcategoryId &&
      other.locationId == locationId &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.featuredOnly == featuredOnly &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    keyword,
    categoryId,
    subcategoryId,
    locationId,
    minPrice,
    maxPrice,
    featuredOnly,
    sort,
  );
}

/// Search abstraction. Firestore has no full-text search, so the current
/// implementation uses keyword tokens; a dedicated engine (Algolia,
/// Typesense, ...) can replace it by implementing this interface only.
abstract interface class ListingSearchService {
  Future<ListingPage> search(
    SearchQuery query, {
    Object? cursor,
    int limit = 20,
  });
}
