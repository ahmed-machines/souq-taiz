import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/features/listings/domain/entities/listing.dart';
import 'package:souq_taiz/features/search/domain/keyword_tokenizer.dart';
import 'package:souq_taiz/features/search/domain/query_matcher.dart';
import 'package:souq_taiz/features/search/domain/search_query.dart';

Listing _l(
  String id, {
  String title = 'item title',
  num price = 100,
  String cat = 'cars',
  String loc = 'taiz',
  bool featured = false,
  ListingStatus status = ListingStatus.published,
  DateTime? at,
}) => Listing(
  id: id,
  ownerId: 'o',
  ownerName: 'n',
  title: title,
  description: 'description text here',
  categoryId: cat,
  locationId: loc,
  price: price,
  priceType: PriceType.fixed,
  imageUrls: const [],
  contactPhone: '777123456',
  status: status,
  isFeatured: featured,
  createdAt: at ?? DateTime(2026),
);

void main() {
  group('KeywordTokenizer', () {
    test('normalizes Arabic variants and diacritics', () {
      expect(KeywordTokenizer.normalize('أحمد'), 'احمد');
      expect(KeywordTokenizer.normalize('مَدرسة'), 'مدرسه');
    });

    test('tokenizes, dedupes and drops 1-char tokens', () {
      expect(KeywordTokenizer.tokens('Toyota, toyota a Corolla'), [
        'toyota',
        'corolla',
      ]);
    });

    test('caps token count', () {
      expect(
        KeywordTokenizer.tokens(
          List.generate(30, (i) => 'word$i').join(' '),
        ).length,
        10,
      );
    });
  });

  group('QueryMatcher', () {
    test('only published listings match', () {
      expect(
        QueryMatcher.matches(
          _l('1', status: ListingStatus.pendingReview),
          const SearchQuery(),
        ),
        isFalse,
      );
      expect(QueryMatcher.matches(_l('1'), const SearchQuery()), isTrue);
    });

    test('category, location, featured and price filters', () {
      final l = _l('1', cat: 'phones', loc: 'a', featured: true, price: 500);
      expect(
        QueryMatcher.matches(
          l,
          const SearchQuery(
            categoryId: 'phones',
            locationId: 'a',
            featuredOnly: true,
          ),
        ),
        isTrue,
      );
      expect(
        QueryMatcher.matches(l, const SearchQuery(categoryId: 'cars')),
        isFalse,
      );
      expect(
        QueryMatcher.matches(l, const SearchQuery(minPrice: 600)),
        isFalse,
      );
      expect(
        QueryMatcher.matches(l, const SearchQuery(maxPrice: 400)),
        isFalse,
      );
      expect(
        QueryMatcher.matches(
          l,
          const SearchQuery(minPrice: 500, maxPrice: 500),
        ),
        isTrue,
      );
    });

    test('keyword matches all tokens in title/description', () {
      final l = _l('1', title: 'Toyota Corolla 2015');
      expect(
        QueryMatcher.matches(l, const SearchQuery(keyword: 'toyota 2015')),
        isTrue,
      );
      expect(
        QueryMatcher.matches(l, const SearchQuery(keyword: 'honda')),
        isFalse,
      );
    });

    test('sorting', () {
      final a = _l('a', price: 10, at: DateTime(2026, 1, 1));
      final b = _l('b', price: 20, at: DateTime(2026, 2, 1));
      List<String> sorted(SortOption s) =>
          ([a, b]..sort((x, y) => QueryMatcher.compare(x, y, s)))
              .map((e) => e.id)
              .toList();
      expect(sorted(SortOption.newest), ['b', 'a']);
      expect(sorted(SortOption.oldest), ['a', 'b']);
      expect(sorted(SortOption.priceLow), ['a', 'b']);
      expect(sorted(SortOption.priceHigh), ['b', 'a']);
    });
  });

  group('SearchQuery', () {
    test('copyWith clears and equality', () {
      const q = SearchQuery(categoryId: 'c', subcategoryId: 's', minPrice: 1);
      expect(q.copyWith(clearCategory: true).subcategoryId, isNull);
      expect(q.copyWith(clearMin: true).minPrice, isNull);
      expect(
        const SearchQuery(keyword: 'x') == const SearchQuery(keyword: 'x'),
        isTrue,
      );
    });
  });
}
