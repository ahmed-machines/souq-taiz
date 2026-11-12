import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/extensions/responsive_context.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../listings/presentation/widgets/listing_grid.dart';
import '../../domain/search_query.dart';
import '../controllers/search_controller.dart';
import '../widgets/search_filters.dart';

/// Search results with filters and cursor-based "load more".
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.initialQuery});

  final SearchQuery initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(searchControllerProvider.notifier)
          .setQuery(widget.initialQuery),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);

    final filters = SearchFilters(
      query: state.query,
      onChanged: controller.setQuery,
    );

    final Widget results;
    if (state.isLoading) {
      results = const ListingGridSkeleton(count: 6);
    } else if (state.failure != null && state.items.isEmpty) {
      results = ErrorState(
        message: state.failure!.message(l10n),
        onRetry: controller.refresh,
      );
    } else if (state.items.isEmpty) {
      results = EmptyState(message: l10n.searchEmpty, icon: Icons.search_off);
    } else {
      results = Column(
        children: [
          ListingGrid(listings: state.items),
          const SizedBox(height: AppSpacing.md),
          if (state.failure != null) Text(state.failure!.message(l10n)),
          if (state.isLoadingMore)
            const CircularProgressIndicator()
          else if (state.hasMore)
            OutlinedButton(
              onPressed: controller.loadMore,
              child: Text(l10n.loadMore),
            ),
        ],
      );
    }

    return PageContainer(
      child: context.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: filters),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: results),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExpansionTile(
                  title: Text(l10n.filters),
                  leading: const Icon(Icons.tune),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: filters,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                results,
              ],
            ),
    );
  }
}
