import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../../listings/presentation/controllers/listing_providers.dart';

String statusLabel(AppLocalizations l, ListingStatus s) => switch (s) {
  ListingStatus.draft => l.statusDraft,
  ListingStatus.pendingReview => l.statusPending,
  ListingStatus.published => l.statusPublished,
  ListingStatus.rejected => l.statusRejected,
  ListingStatus.paused => l.statusPaused,
  ListingStatus.sold => l.statusSold,
  ListingStatus.archived => l.statusArchived,
};

/// Seller dashboard: stats and management of own listings.
class SellerDashboardPage extends ConsumerWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(sellerStatsProvider);
    final listings = ref.watch(myListingsProvider);
    final user = ref.watch(currentUserProvider);

    Widget statCard(String label, int value) => Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ],
        ),
      ),
    );

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.sellerDashboard,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go(RouteNames.sellerNew),
                icon: const Icon(Icons.add),
                label: Text(l10n.createListing),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          stats.when(
            loading: () => const SkeletonBox(height: 90),
            error: (e, _) => ErrorState(
              message: FailureMapper.from(e).message(l10n),
              onRetry: () => ref.invalidate(sellerStatsProvider),
            ),
            data: (m) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                statCard(l10n.totalListings, m.values.fold(0, (a, b) => a + b)),
                statCard(l10n.statPublished, m[ListingStatus.published] ?? 0),
                statCard(l10n.statPending, m[ListingStatus.pendingReview] ?? 0),
                statCard(l10n.statRejected, m[ListingStatus.rejected] ?? 0),
                statCard(l10n.statSold, m[ListingStatus.sold] ?? 0),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.myListings, style: Theme.of(context).textTheme.titleLarge),
          listings.when(
            loading: () => const SkeletonBox(height: 120),
            error: (e, _) => ErrorState(
              message: FailureMapper.from(e).message(l10n),
              onRetry: () => ref.invalidate(myListingsProvider),
            ),
            data: (page) => page.items.isEmpty
                ? EmptyState(message: l10n.noListings)
                : Column(
                    children: [
                      for (final l in page.items)
                        _ListingTile(
                          listing: l,
                          canPublish: user?.canPublish ?? false,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ListingTile extends ConsumerWidget {
  const _ListingTile({required this.listing, required this.canPublish});

  final Listing listing;
  final bool canPublish;

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    ListingStatus status,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(listingRepositoryProvider)
          .setOwnerStatus(listing.id, status);
      ref
        ..invalidate(myListingsProvider)
        ..invalidate(sellerStatsProvider);
    } catch (e) {
      if (context.mounted) {
        showToast(context, FailureMapper.from(e).message(l10n));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final s = listing.status;
    return Card(
      child: ListTile(
        title: Text(
          listing.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${statusLabel(l10n, s)} · ${PriceFormatter.format(listing.price, currency: listing.currency, locale: lang)}'
          '${s == ListingStatus.rejected && listing.rejectionReason != null ? '\n${l10n.rejectionReason}: ${listing.rejectionReason}' : ''}',
        ),
        onTap: () => context.go(RouteNames.listingPath(listing.id)),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'edit':
                context.go(RouteNames.sellerEditPath(listing.id));
              case 'pause':
                await _setStatus(context, ref, ListingStatus.paused);
              case 'resume':
                // Resuming returns to review only if never approved is not tracked;
                // rules allow paused -> published only via re-review.
                await _setStatus(context, ref, ListingStatus.pendingReview);
              case 'sold':
                await _setStatus(context, ref, ListingStatus.sold);
              case 'delete':
                if (await confirmDialog(
                      context,
                      title: l10n.deleteListing,
                      message: l10n.deleteConfirm,
                    ) &&
                    context.mounted) {
                  await _setStatus(context, ref, ListingStatus.archived);
                }
            }
          },
          itemBuilder: (_) => [
            if (canPublish)
              PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
            if (s == ListingStatus.published)
              PopupMenuItem(value: 'pause', child: Text(l10n.pause)),
            if (s == ListingStatus.paused && canPublish)
              PopupMenuItem(value: 'resume', child: Text(l10n.resume)),
            if (s == ListingStatus.published)
              PopupMenuItem(value: 'sold', child: Text(l10n.markSold)),
            if (s != ListingStatus.archived)
              PopupMenuItem(value: 'delete', child: Text(l10n.deleteListing)),
          ],
        ),
      ),
    );
  }
}
