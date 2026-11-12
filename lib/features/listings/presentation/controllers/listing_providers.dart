import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../locations/presentation/controllers/location_providers.dart';
import '../../../search/domain/search_query.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';

final listingDetailProvider = FutureProvider.family<Listing?, String>(
  (ref, id) => ref.watch(listingRepositoryProvider).getById(id),
);

final relatedListingsProvider = FutureProvider.family<List<Listing>, Listing>(
  (ref, listing) => ref.watch(listingRepositoryProvider).getRelated(listing),
);

/// Featured listings for the home page.
final featuredListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final page = await ref
      .watch(searchServiceProvider)
      .search(const SearchQuery(featuredOnly: true), limit: 8);
  return page.items;
});

/// Latest published listings for the home page.
final latestListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final page = await ref
      .watch(searchServiceProvider)
      .search(const SearchQuery(), limit: 12);
  return page.items;
});

/// Listings for the location chosen in the header (all locations if none).
final recommendedListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  final page = await ref
      .watch(searchServiceProvider)
      .search(
        SearchQuery(locationId: location, sort: SortOption.newest),
        limit: 8,
      );
  return page.items;
});

/// Listings of the signed-in seller (all statuses), first page.
final myListingsProvider = FutureProvider<ListingPage>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return ListingPage.empty;
  return ref.watch(listingRepositoryProvider).getByOwner(user.uid, limit: 50);
});

final sellerStatsProvider = FutureProvider<Map<ListingStatus, int>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const {};
  return ref.watch(listingRepositoryProvider).countByStatus(user.uid);
});
