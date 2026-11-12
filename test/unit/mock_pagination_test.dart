import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/features/search/domain/search_query.dart';
import 'package:souq_taiz/shared/mock/mock_repositories.dart';

void main() {
  test(
    'demo search paginates with an integer cursor until exhausted',
    () async {
      final repo = MockListingRepository();
      final p1 = await repo.search(const SearchQuery(), limit: 4);
      expect(p1.items.length, 4);
      expect(p1.hasMore, isTrue);
      final p2 = await repo.search(
        const SearchQuery(),
        cursor: p1.cursor,
        limit: 4,
      );
      final p3 = await repo.search(
        const SearchQuery(),
        cursor: p2.cursor,
        limit: 4,
      );
      expect(p3.items.length, 2);
      expect(p3.hasMore, isFalse);
      final ids = [
        ...p1.items,
        ...p2.items,
        ...p3.items,
      ].map((e) => e.id).toSet();
      expect(ids.length, 10); // no duplicates across pages
    },
  );
}
