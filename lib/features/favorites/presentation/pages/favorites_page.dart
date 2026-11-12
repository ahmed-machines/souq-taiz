import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../../listings/presentation/widgets/listing_grid.dart';
import '../controllers/favorites_controller.dart';

/// Favorite listing details (only published ones are shown).
final favoriteListingsProvider = FutureProvider.autoDispose<List<Listing>>((
  ref,
) async {
  final ids = await ref.watch(favoriteIdsProvider.future);
  final repo = ref.watch(listingRepositoryProvider);
  final results = await Future.wait(ids.take(50).map(repo.getById));
  return results.whereType<Listing>().where((l) => l.isPublic).toList();
});

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.favoritesTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          AsyncListingGrid(
            listings: ref.watch(favoriteListingsProvider),
            emptyMessage: l10n.favoritesEmpty,
            onRetry: () => ref.invalidate(favoriteListingsProvider),
          ),
        ],
      ),
    );
  }
}
