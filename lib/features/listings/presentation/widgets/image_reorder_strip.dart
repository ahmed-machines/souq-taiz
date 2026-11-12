import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/usecases/listing_input.dart';

/// Horizontally reorderable image strip. The first image is the cover.
class ImageReorderStrip extends StatelessWidget {
  const ImageReorderStrip({
    super.key,
    required this.images,
    required this.onChanged,
  });

  final List<ListingImage> images;
  final ValueChanged<List<ListingImage>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 120,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: true,
        itemCount: images.length,
        onReorder: (from, to) {
          final list = [...images];
          final item = list.removeAt(from);
          list.insert(to > from ? to - 1 : to, item);
          onChanged(list);
        },
        itemBuilder: (context, i) {
          final img = images[i];
          return Padding(
            key: ValueKey('img-$i-${identityHashCode(img)}'),
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: switch (img) {
                      LocalImage(:final picked) => Image.memory(
                        picked.bytes,
                        fit: BoxFit.cover,
                      ),
                      RemoteImage(:final url) => CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                      ),
                    },
                  ),
                ),
                if (i == 0)
                  PositionedDirectional(
                    top: 4,
                    start: 4,
                    child: Chip(
                      label: Text(l10n.coverBadge),
                      backgroundColor: scheme.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: Row(
                    children: [
                      if (i != 0)
                        IconButton.filledTonal(
                          tooltip: l10n.setCover,
                          iconSize: 18,
                          icon: const Icon(Icons.star_outline),
                          onPressed: () {
                            final list = [...images];
                            list.insert(0, list.removeAt(i));
                            onChanged(list);
                          },
                        ),
                      IconButton.filledTonal(
                        tooltip: l10n.removeImage,
                        iconSize: 18,
                        icon: const Icon(Icons.close),
                        onPressed: () => onChanged([...images]..removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
