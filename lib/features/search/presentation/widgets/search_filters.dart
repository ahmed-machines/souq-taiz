import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../categories/presentation/controllers/category_providers.dart';
import '../../../locations/presentation/controllers/location_providers.dart';
import '../../domain/search_query.dart';

/// Filter + sort controls. Emits a new [SearchQuery] on apply/change.
class SearchFilters extends ConsumerStatefulWidget {
  const SearchFilters({
    super.key,
    required this.query,
    required this.onChanged,
  });

  final SearchQuery query;
  final ValueChanged<SearchQuery> onChanged;

  @override
  ConsumerState<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends ConsumerState<SearchFilters> {
  late final TextEditingController _keyword;
  late final TextEditingController _min;
  late final TextEditingController _max;

  @override
  void initState() {
    super.initState();
    _keyword = TextEditingController(text: widget.query.keyword);
    _min = TextEditingController(text: widget.query.minPrice?.toString() ?? '');
    _max = TextEditingController(text: widget.query.maxPrice?.toString() ?? '');
  }

  @override
  void dispose() {
    _keyword.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _apply() {
    final min = num.tryParse(_min.text.trim());
    final max = num.tryParse(_max.text.trim());
    widget.onChanged(
      widget.query.copyWith(
        keyword: _keyword.text.trim(),
        minPrice: min,
        clearMin: min == null,
        maxPrice: max,
        clearMax: max == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final q = widget.query;
    final categories = ref.watch(topCategoriesProvider);
    final subs = ref.watch(subcategoriesProvider(q.categoryId));
    final locations = ref.watch(locationsProvider).value ?? const [];

    Widget gap() => const SizedBox(height: AppSpacing.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _keyword,
          decoration: InputDecoration(
            labelText: l10n.search,
            prefixIcon: const Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _apply(),
        ),
        gap(),
        DropdownButtonFormField<String?>(
          key: ValueKey('cat-${q.categoryId}'),
          initialValue: q.categoryId,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.category),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.allOption)),
            for (final c in categories)
              DropdownMenuItem(value: c.id, child: Text(c.name.of(lang))),
          ],
          onChanged: (v) => widget.onChanged(
            q.copyWith(categoryId: v, clearCategory: v == null),
          ),
        ),
        if (subs.isNotEmpty) ...[
          gap(),
          DropdownButtonFormField<String?>(
            key: ValueKey('sub-${q.subcategoryId}'),
            initialValue: q.subcategoryId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.subcategory),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.allOption)),
              for (final c in subs)
                DropdownMenuItem(value: c.id, child: Text(c.name.of(lang))),
            ],
            onChanged: (v) => widget.onChanged(
              q.copyWith(subcategoryId: v, clearSubcategory: v == null),
            ),
          ),
        ],
        gap(),
        DropdownButtonFormField<String?>(
          key: ValueKey('loc-${q.locationId}'),
          initialValue: q.locationId,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.location),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.allLocations)),
            for (final l in locations)
              DropdownMenuItem(value: l.id, child: Text(l.name.of(lang))),
          ],
          onChanged: (v) => widget.onChanged(
            q.copyWith(locationId: v, clearLocation: v == null),
          ),
        ),
        gap(),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _min,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.minPrice),
                onSubmitted: (_) => _apply(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _max,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.maxPrice),
                onSubmitted: (_) => _apply(),
              ),
            ),
          ],
        ),
        gap(),
        DropdownButtonFormField<SortOption>(
          key: ValueKey('sort-${q.sort}'),
          initialValue: q.sort,
          decoration: InputDecoration(labelText: l10n.sortBy),
          items: [
            DropdownMenuItem(
              value: SortOption.newest,
              child: Text(l10n.sortNewest),
            ),
            DropdownMenuItem(
              value: SortOption.oldest,
              child: Text(l10n.sortOldest),
            ),
            DropdownMenuItem(
              value: SortOption.priceLow,
              child: Text(l10n.sortPriceLow),
            ),
            DropdownMenuItem(
              value: SortOption.priceHigh,
              child: Text(l10n.sortPriceHigh),
            ),
          ],
          onChanged: (v) => widget.onChanged(q.copyWith(sort: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.featuredOnly),
          value: q.featuredOnly,
          onChanged: (v) => widget.onChanged(q.copyWith(featuredOnly: v)),
        ),
        FilledButton(onPressed: _apply, child: Text(l10n.search)),
        TextButton(
          onPressed: () {
            _keyword.clear();
            _min.clear();
            _max.clear();
            widget.onChanged(const SearchQuery());
          },
          child: Text(l10n.clearFilters),
        ),
      ],
    );
  }
}
