import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/listings/domain/entities/listing.dart';
import '../../features/listings/domain/repositories/listing_repository.dart';
import '../../features/locations/domain/entities/location.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/search/domain/query_matcher.dart';
import '../../features/search/domain/search_query.dart';

// =============================================================================
// DEMO DATA ONLY. Used when Firebase is not configured so the UI can be
// developed and previewed. Nothing here is persisted or sent to any backend.
// Location names are placeholders for UI development, not an official list.
// =============================================================================

const _cat = <(String, String, String, String)>[
  ('cars', 'سيارات ومركبات', 'Cars & Vehicles', 'car'),
  ('real_estate', 'عقارات', 'Real Estate', 'home'),
  ('phones', 'جوالات', 'Mobile Phones', 'phone'),
  ('electronics', 'حاسوب وإلكترونيات', 'Computers & Electronics', 'computer'),
  ('furniture', 'أثاث وأجهزة منزلية', 'Furniture & Appliances', 'chair'),
  ('fashion', 'أزياء وإكسسوارات', 'Fashion & Accessories', 'fashion'),
  ('jobs', 'وظائف', 'Jobs', 'work'),
  ('services', 'خدمات', 'Services', 'build'),
  ('pets', 'حيوانات وطيور', 'Animals & Pets', 'pets'),
  ('other', 'منتجات أخرى', 'Other Products', 'category'),
];

class MockCategoryRepository implements CategoryRepository {
  final List<Category> _items = [
    for (var i = 0; i < _cat.length; i++)
      Category(
        id: _cat[i].$1,
        name: LocalizedName(ar: _cat[i].$2, en: _cat[i].$3),
        order: i,
        iconKey: _cat[i].$4,
      ),
    const Category(
      id: 'phones_smart',
      name: LocalizedName(ar: 'هواتف ذكية', en: 'Smartphones'),
      order: 0,
      parentId: 'phones',
    ),
    const Category(
      id: 'cars_used',
      name: LocalizedName(ar: 'سيارات مستعملة', en: 'Used cars'),
      order: 0,
      parentId: 'cars',
    ),
  ];

  @override
  Future<List<Category>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> upsert(Category category) async {
    _items
      ..removeWhere((c) => c.id == category.id)
      ..add(category);
  }

  @override
  Future<void> deactivate(String categoryId) async =>
      _items.removeWhere((c) => c.id == categoryId);
}

class MockLocationRepository implements LocationRepository {
  final List<Location> _items = [
    const Location(
      id: 'taiz',
      name: LocalizedName(ar: 'محافظة تعز', en: 'Taiz Governorate'),
    ),
    const Location(
      id: 'taiz_city',
      name: LocalizedName(ar: 'مدينة تعز (عينة)', en: 'Taiz City (sample)'),
      parentId: 'taiz',
    ),
    const Location(
      id: 'taiz_area_2',
      name: LocalizedName(ar: 'منطقة تجريبية 2', en: 'Sample area 2'),
      parentId: 'taiz',
    ),
  ];

  @override
  Future<List<Location>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> upsert(Location location) async {
    _items
      ..removeWhere((l) => l.id == location.id)
      ..add(location);
  }

  @override
  Future<void> deactivate(String locationId) async =>
      _items.removeWhere((l) => l.id == locationId);
}

/// In-memory listings with sample items; supports the full repository API.
class MockListingRepository implements ListingRepository, ListingSearchService {
  MockListingRepository() : _items = _sample();

  final List<Listing> _items;
  int _seq = 0;

  static List<Listing> _sample() {
    final now = DateTime.now();
    const samples = <(String, String, String, num, bool)>[
      ('تويوتا كورولا 2015 نظيفة', 'cars', 'cars_used', 6500000, true),
      ('شقة للإيجار 3 غرف', 'real_estate', '', 120000, false),
      ('آيفون 13 بحالة ممتازة', 'phones', 'phones_smart', 450000, true),
      ('لابتوب ديل i5 جيل عاشر', 'electronics', '', 380000, false),
      ('غرفة نوم كاملة', 'furniture', '', 520000, false),
      ('ساعة رجالية أنيقة', 'fashion', '', 45000, false),
      ('مطلوب محاسب', 'jobs', '', 1, false),
      ('خدمات صيانة منزلية', 'services', '', 15000, false),
      ('قطط شيرازي', 'pets', '', 90000, false),
      ('دراجة هوائية للبيع', 'other', '', 60000, true),
    ];
    return [
      for (var i = 0; i < samples.length; i++)
        Listing(
          id: 'demo_$i',
          ownerId: 'demo_seller',
          ownerName: 'بائع تجريبي',
          title: samples[i].$1,
          description:
              'هذا إعلان تجريبي لأغراض تطوير الواجهة فقط. ${samples[i].$1}.',
          categoryId: samples[i].$2,
          subcategoryId: samples[i].$3.isEmpty ? null : samples[i].$3,
          locationId: 'taiz_city',
          price: samples[i].$4,
          priceType: i.isEven ? PriceType.negotiable : PriceType.fixed,
          imageUrls: const [],
          contactPhone: '777123456',
          status: ListingStatus.published,
          isFeatured: samples[i].$5,
          createdAt: now.subtract(Duration(hours: i * 7)),
        ),
    ];
  }

  @override
  String newId() => 'local_${_seq++}';

  @override
  Future<Listing?> getById(String id) async =>
      _items.where((l) => l.id == id).firstOrNull;

  @override
  Future<void> create(Listing listing) async => _items.add(listing);

  @override
  Future<void> update(Listing listing) async {
    final i = _items.indexWhere((l) => l.id == listing.id);
    if (i >= 0) _items[i] = listing;
  }

  @override
  Future<void> setOwnerStatus(String id, ListingStatus status) async {
    final i = _items.indexWhere((l) => l.id == id);
    if (i < 0) return;
    final l = _items[i];
    _items[i] = Listing(
      id: l.id,
      ownerId: l.ownerId,
      ownerName: l.ownerName,
      title: l.title,
      description: l.description,
      categoryId: l.categoryId,
      subcategoryId: l.subcategoryId,
      locationId: l.locationId,
      price: l.price,
      priceType: l.priceType,
      imageUrls: l.imageUrls,
      contactPhone: l.contactPhone,
      status: status,
      createdAt: l.createdAt,
    );
  }

  @override
  Future<ListingPage> getByOwner(
    String ownerId, {
    ListingStatus? status,
    Object? cursor,
    int limit = 20,
  }) async {
    final all =
        _items
            .where(
              (l) =>
                  l.ownerId == ownerId &&
                  (status == null || l.status == status),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _page(all, cursor, limit);
  }

  @override
  Future<List<Listing>> getRelated(Listing listing, {int limit = 6}) async =>
      _items
          .where(
            (l) =>
                l.isPublic &&
                l.id != listing.id &&
                l.categoryId == listing.categoryId,
          )
          .take(limit)
          .toList();

  @override
  Future<Map<ListingStatus, int>> countByStatus(String ownerId) async => {
    for (final s in ListingStatus.values)
      s: _items.where((l) => l.ownerId == ownerId && l.status == s).length,
  };

  @override
  Future<ListingPage> search(
    SearchQuery query, {
    Object? cursor,
    int limit = 20,
  }) async {
    final all = _items.where((l) => QueryMatcher.matches(l, query)).toList()
      ..sort((a, b) => QueryMatcher.compare(a, b, query.sort));
    return _page(all, cursor, limit);
  }

  ListingPage _page(List<Listing> all, Object? cursor, int limit) {
    final start = cursor is int ? cursor : 0;
    final end = (start + limit).clamp(0, all.length);
    return ListingPage(
      items: all.sublist(start.clamp(0, all.length), end),
      cursor: end,
      hasMore: end < all.length,
    );
  }
}
