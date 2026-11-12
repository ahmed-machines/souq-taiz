import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/extensions/responsive_context.dart';
import '../../../../core/utils/contact_links.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../categories/presentation/controllers/category_providers.dart';
import '../../../locations/presentation/controllers/location_providers.dart';
import '../../../reviews/presentation/widgets/seller_reviews_section.dart';
import '../../domain/entities/listing.dart';
import '../controllers/listing_providers.dart';
import '../widgets/favorite_button.dart';
import '../widgets/image_gallery.dart';
import '../widgets/listing_grid.dart';
import '../widgets/report_dialog.dart';

/// Listing details page.
class ListingDetailsPage extends ConsumerWidget {
  const ListingDetailsPage({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(listingDetailProvider(listingId));
    final user = ref.watch(currentUserProvider);

    return async.when(
      loading: () => const PageContainer(child: SkeletonBox(height: 320)),
      error: (e, _) => PageContainer(
        child: ErrorState(
          message: FailureMapper.from(e).message(l10n),
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
      ),
      data: (listing) {
        final visible =
            listing != null &&
            (listing.isPublic ||
                user?.uid == listing.ownerId ||
                (user?.isAdmin ?? false));
        if (!visible) {
          return PageContainer(
            child: EmptyState(
              message: l10n.listingNotFound,
              icon: Icons.search_off,
            ),
          );
        }
        return PageContainer(child: _Body(listing: listing));
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final locations = ref.watch(locationsProvider).value ?? const [];
    final categoryName =
        categories
            .where((c) => c.id == (listing.subcategoryId ?? listing.categoryId))
            .firstOrNull
            ?.name
            .of(lang) ??
        '';
    final locationName =
        locations
            .where((l) => l.id == listing.locationId)
            .firstOrNull
            ?.name
            .of(lang) ??
        '';
    final isOwner = user?.uid == listing.ownerId;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                listing.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            FavoriteButton(listingId: listing.id),
          ],
        ),
        Text(
          PriceFormatter.format(
            listing.price,
            currency: listing.currency,
            locale: lang,
          ),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          listing.priceType == PriceType.negotiable
              ? l10n.negotiable
              : l10n.fixedPrice,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            if (categoryName.isNotEmpty)
              Chip(
                avatar: const Icon(Icons.category_outlined, size: 16),
                label: Text(categoryName),
              ),
            if (locationName.isNotEmpty)
              Chip(
                avatar: const Icon(Icons.place_outlined, size: 16),
                label: Text(locationName),
              ),
            Chip(
              avatar: const Icon(Icons.schedule, size: 16),
              label: Text(
                '${l10n.publishedOn}: ${DateFormat.yMMMd(lang).format(listing.createdAt)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.description, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        SelectableText(listing.description),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${l10n.seller}: ${listing.ownerName}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!isOwner) _ContactActions(listing: listing),
        const SizedBox(height: AppSpacing.sm),
        if (user != null && !isOwner)
          TextButton.icon(
            onPressed: () => showReportDialog(
              context,
              ref,
              listingId: listing.id,
              reporterId: user.uid,
            ),
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.reportListing),
          ),
      ],
    );

    final gallery = ImageGallery(urls: listing.imageUrls);
    final related = ref.watch(relatedListingsProvider(listing));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: gallery),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: info),
            ],
          )
        else ...[
          gallery,
          const SizedBox(height: AppSpacing.md),
          info,
        ],
        const Divider(height: AppSpacing.xl),
        SellerReviewsSection(sellerId: listing.ownerId),
        const Divider(height: AppSpacing.xl),
        Text(
          l10n.relatedListings,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        AsyncListingGrid(
          listings: related,
          onRetry: () => ref.invalidate(relatedListingsProvider(listing)),
          emptyMessage: l10n.noData,
        ),
      ],
    );
  }
}

class _ContactActions extends ConsumerWidget {
  const _ContactActions({required this.listing});

  final Listing listing;

  Future<void> _open(BuildContext context, Uri? uri) async {
    final l10n = AppLocalizations.of(context);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) showToast(context, l10n.errUnknown);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final wa = ContactLinks.whatsApp(
      listing.contactPhone,
      message: l10n.waMessage(listing.title),
    );
    final tel = ContactLinks.phoneCall(listing.contactPhone);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (wa != null)
          FilledButton.icon(
            onPressed: () => _open(context, wa),
            icon: const Icon(Icons.chat),
            label: Text(l10n.contactWhatsApp),
          ),
        if (tel != null)
          OutlinedButton.icon(
            onPressed: () => _open(context, tel),
            icon: const Icon(Icons.call),
            label: Text(l10n.callSeller),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.message_outlined),
          label: Text(l10n.chatWithSeller),
          onPressed: () async {
            if (user == null) {
              showToast(context, l10n.loginRequired);
              context.go(RouteNames.login);
              return;
            }
            try {
              final id = await ref
                  .read(messagingRepositoryProvider)
                  .openConversation(
                    listingId: listing.id,
                    listingTitle: listing.title,
                    buyerId: user.uid,
                    buyerName: user.displayName,
                    sellerId: listing.ownerId,
                    sellerName: listing.ownerName,
                  );
              if (context.mounted) context.go(RouteNames.chatPath(id));
            } catch (e) {
              if (context.mounted) {
                showToast(context, FailureMapper.from(e).message(l10n));
              }
            }
          },
        ),
      ],
    );
  }
}
