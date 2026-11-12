import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/extensions/responsive_context.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/listing.dart';
import 'listing_card.dart';

/// Responsive grid of listing cards (non-scrolling; place inside a scroll view).
class ListingGrid extends StatelessWidget {
  const ListingGrid({super.key, required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: listings.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.gridColumns,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.78,
    ),
    itemBuilder: (_, i) => ListingCard(
      listing: listings[i],
      onTap: () => context.go(RouteNames.listingPath(listings[i].id)),
    ),
  );
}

/// Loading skeleton matching [ListingGrid].
class ListingGridSkeleton extends StatelessWidget {
  const ListingGridSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: count,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.gridColumns,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.78,
    ),
    itemBuilder: (_, _) => const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SkeletonBox(height: double.infinity)),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(),
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(width: 80),
          ],
        ),
      ),
    ),
  );
}

/// Renders an [AsyncValue] list of listings with loading/error/empty states.
class AsyncListingGrid extends StatelessWidget {
  const AsyncListingGrid({
    super.key,
    required this.listings,
    this.onRetry,
    this.emptyMessage,
  });

  final AsyncValue<List<Listing>> listings;
  final VoidCallback? onRetry;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return listings.when(
      loading: () => const ListingGridSkeleton(),
      error: (e, _) => ErrorState(
        message: FailureMapper.from(e).message(l10n),
        onRetry: onRetry,
      ),
      data: (items) => items.isEmpty
          ? EmptyState(message: emptyMessage ?? l10n.searchEmpty)
          : ListingGrid(listings: items),
    );
  }
}
