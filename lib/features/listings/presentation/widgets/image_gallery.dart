import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_spacing.dart';

/// Swipeable image gallery with thumbnails.
class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key, required this.urls});

  final List<String> urls;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (widget.urls.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_outlined, size: 48, color: scheme.outline),
                Text(AppLocalizations.of(context).noImage),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: widget.urls[i],
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    ColoredBox(color: scheme.surfaceContainerHighest),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        if (widget.urls.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.urls.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => InkWell(
                onTap: () => _controller.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                ),
                child: Container(
                  width: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: i == _index ? scheme.primary : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.urls[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
