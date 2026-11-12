import '../../listings/domain/entities/listing.dart';
import 'keyword_tokenizer.dart';
import 'search_query.dart';

/// In-memory matching/sorting. Used by the demo search service and for the
/// client-side refinements Firestore cannot express together with ordering.
abstract final class QueryMatcher {
  static bool matches(Listing l, SearchQuery q) {
    if (!l.isPublic) return false;
    if (q.categoryId != null && l.categoryId != q.categoryId) return false;
    if (q.subcategoryId != null && l.subcategoryId != q.subcategoryId) {
      return false;
    }
    if (q.locationId != null && l.locationId != q.locationId) return false;
    if (q.featuredOnly && !l.isFeatured) return false;
    if (!matchesPrice(l, q)) return false;
    final tokens = KeywordTokenizer.tokens(q.keyword);
    if (tokens.isNotEmpty) {
      final haystack = KeywordTokenizer.normalize(
        '${l.title} ${l.description}',
      );
      if (!tokens.every(haystack.contains)) return false;
    }
    return true;
  }

  static bool matchesPrice(Listing l, SearchQuery q) =>
      (q.minPrice == null || l.price >= q.minPrice!) &&
      (q.maxPrice == null || l.price <= q.maxPrice!);

  static int compare(Listing a, Listing b, SortOption sort) => switch (sort) {
    SortOption.newest => b.createdAt.compareTo(a.createdAt),
    SortOption.oldest => a.createdAt.compareTo(b.createdAt),
    SortOption.priceLow => a.price.compareTo(b.price),
    SortOption.priceHigh => b.price.compareTo(a.price),
  };
}
