import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/features/favorites/data/repositories/firestore_favorites_repository.dart';
import 'package:souq_taiz/features/listings/data/models/listing_mapper.dart';
import 'package:souq_taiz/features/listings/data/repositories/firestore_listing_repository.dart';
import 'package:souq_taiz/features/listings/domain/entities/listing.dart';
import 'package:souq_taiz/features/messaging/data/repositories/firestore_messaging_repository.dart';
import 'package:souq_taiz/features/search/data/firestore_search_service.dart';
import 'package:souq_taiz/features/search/domain/search_query.dart';

Listing _listing(
  String id, {
  String owner = 'o1',
  String title = 'Toyota Corolla',
  num price = 1000,
  String cat = 'cars',
  String loc = 'taiz',
  ListingStatus status = ListingStatus.pendingReview,
}) => Listing(
  id: id,
  ownerId: owner,
  ownerName: 'Owner',
  title: title,
  description: 'A long enough description',
  categoryId: cat,
  locationId: loc,
  price: price,
  priceType: PriceType.fixed,
  imageUrls: const ['https://x/1.jpg'],
  contactPhone: '777123456',
  status: status,
  createdAt: DateTime(2026),
);

void main() {
  group('FirestoreListingRepository', () {
    late FakeFirebaseFirestore db;
    late FirestoreListingRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = FirestoreListingRepository(db);
    });

    test('create stores owner-safe defaults and keywords', () async {
      await repo.create(_listing('a'));
      final data = (await db.collection('listings').doc('a').get()).data()!;
      expect(data['status'], 'pending_review');
      expect(data['isFeatured'], false);
      expect(data['viewCount'], 0);
      expect(data['searchKeywords'], containsAll(['toyota', 'corolla']));
      expect(data['coverImageUrl'], 'https://x/1.jpg');
    });

    test('getById maps back to the entity', () async {
      await repo.create(_listing('a'));
      final l = await repo.getById('a');
      expect(l?.title, 'Toyota Corolla');
      expect(l?.priceType, PriceType.fixed);
      expect(await repo.getById('missing'), isNull);
    });

    test('owner status change and countByStatus', () async {
      await repo.create(_listing('a'));
      await repo.create(_listing('b'));
      await repo.create(_listing('c', owner: 'other'));
      await repo.setOwnerStatus('b', ListingStatus.archived);
      final counts = await repo.countByStatus('o1');
      expect(counts[ListingStatus.pendingReview], 1);
      expect(counts[ListingStatus.archived], 1);
      expect(counts[ListingStatus.published], 0);
    });

    // Note: fake_cloud_firestore applies limit before startAfterDocument, so the
    // second page is verified against the emulator, not here.
    test('getByOwner returns a bounded page with a cursor', () async {
      for (var i = 0; i < 5; i++) {
        await repo.create(_listing('l$i'));
      }
      final first = await repo.getByOwner('o1', limit: 3);
      expect(first.items.length, 3);
      expect(first.hasMore, isTrue);
      expect(first.cursor, isNotNull);
    });

    test('related excludes the listing itself and non-published', () async {
      await db.collection('listings').doc('p1').set({
        ...ListingMapper.toCreateMap(_listing('p1')),
        'status': 'published',
      });
      await db.collection('listings').doc('p2').set({
        ...ListingMapper.toCreateMap(_listing('p2')),
        'status': 'published',
      });
      await db.collection('listings').doc('p3').set({
        ...ListingMapper.toCreateMap(_listing('p3')),
        'status': 'pending_review',
      });
      final related = await repo.getRelated(
        _listing('p1', status: ListingStatus.published),
      );
      expect(related.map((e) => e.id), ['p2']);
    });
  });

  group('FirestoreSearchService', () {
    late FakeFirebaseFirestore db;
    late FirestoreSearchService search;

    Future<void> seed(
      String id, {
      String title = 'Toyota Corolla',
      num price = 1000,
      String cat = 'cars',
      String loc = 'taiz',
      bool featured = false,
      String status = 'published',
    }) => db.collection('listings').doc(id).set({
      ...ListingMapper.toCreateMap(
        _listing(id, title: title, price: price, cat: cat, loc: loc),
      ),
      'status': status,
      'isFeatured': featured,
      'createdAt': Timestamp.fromDate(
        DateTime(
          2026,
          1,
          int.parse(id.replaceAll(RegExp(r'\D'), '').padLeft(1, '0')) + 1,
        ),
      ),
    });

    setUp(() async {
      db = FakeFirebaseFirestore();
      search = FirestoreSearchService(db);
      await seed('1', price: 500);
      await seed(
        '2',
        title: 'iPhone 13',
        price: 400000,
        cat: 'phones',
        featured: true,
      );
      await seed('3', title: 'Toyota Hilux', price: 9000000);
      await seed('4', status: 'pending_review');
    });

    test('returns only published listings, newest first', () async {
      final page = await search.search(const SearchQuery());
      expect(page.items.map((e) => e.id), ['3', '2', '1']);
    });

    test('category / featured / keyword filters', () async {
      expect(
        (await search.search(
          const SearchQuery(categoryId: 'phones'),
        )).items.map((e) => e.id),
        ['2'],
      );
      expect(
        (await search.search(
          const SearchQuery(featuredOnly: true),
        )).items.map((e) => e.id),
        ['2'],
      );
      expect(
        (await search.search(
          const SearchQuery(keyword: 'toyota'),
        )).items.map((e) => e.id),
        ['3', '1'],
      );
      expect(
        (await search.search(
          const SearchQuery(keyword: 'toyota hilux'),
        )).items.map((e) => e.id),
        ['3'],
      );
    });

    test('price range with date sort is refined client-side', () async {
      final page = await search.search(
        const SearchQuery(minPrice: 1000, maxPrice: 1000000),
      );
      expect(page.items.map((e) => e.id), ['2']);
    });

    test('price sorting with range', () async {
      final asc = await search.search(
        const SearchQuery(sort: SortOption.priceLow, minPrice: 100),
      );
      expect(asc.items.map((e) => e.id), ['1', '2', '3']);
      final desc = await search.search(
        const SearchQuery(sort: SortOption.priceHigh),
      );
      expect(desc.items.map((e) => e.id), ['3', '2', '1']);
    });

    test('first page is bounded and reports more results', () async {
      final p1 = await search.search(const SearchQuery(), limit: 2);
      expect(p1.items.length, 2);
      expect(p1.hasMore, isTrue);
      expect(p1.cursor, isNotNull);
    });
  });

  group('FirestoreFavoritesRepository', () {
    test('adding twice yields one favorite; remove deletes', () async {
      final repo = FirestoreFavoritesRepository(FakeFirebaseFirestore());
      await repo.add('u1', 'l1');
      await repo.add('u1', 'l1');
      expect(await repo.watchIds('u1').first, {'l1'});
      await repo.remove('u1', 'l1');
      expect(await repo.watchIds('u1').first, isEmpty);
    });
  });

  group('FirestoreMessagingRepository', () {
    late FirestoreMessagingRepository repo;

    setUp(() => repo = FirestoreMessagingRepository(FakeFirebaseFirestore()));

    Future<String> open() => repo.openConversation(
      listingId: 'l1',
      listingTitle: 'T',
      buyerId: 'buyer',
      buyerName: 'B',
      sellerId: 'seller',
      sellerName: 'S',
    );

    test('opening twice reuses the deterministic conversation', () async {
      expect(await open(), 'l1_buyer');
      expect(await open(), 'l1_buyer');
      final convs = await repo.watchConversations('buyer').first;
      expect(convs.length, 1);
      expect(convs.single.otherName('buyer'), 'S');
    });

    test('send, last message and read receipts', () async {
      final id = await open();
      await repo.sendMessage(
        conversationId: id,
        senderId: 'buyer',
        text: '  hello  ',
      );
      final msgs = await repo.watchMessages(id).first;
      expect(msgs.single.text, 'hello');
      expect(msgs.single.isRead, isFalse);
      expect(
        (await repo.watchConversations('seller').first).single.lastMessage,
        'hello',
      );

      await repo.markRead(id, 'buyer'); // sender cannot mark own message read
      expect((await repo.watchMessages(id).first).single.isRead, isFalse);
      await repo.markRead(id, 'seller');
      expect((await repo.watchMessages(id).first).single.isRead, isTrue);
    });

    test('rejects empty and oversized messages', () async {
      final id = await open();
      expect(
        () => repo.sendMessage(
          conversationId: id,
          senderId: 'buyer',
          text: '   ',
        ),
        throwsArgumentError,
      );
      expect(
        () => repo.sendMessage(
          conversationId: id,
          senderId: 'buyer',
          text: 'x' * 1001,
        ),
        throwsArgumentError,
      );
    });
  });
}
