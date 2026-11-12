import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/responsive_context.dart';
import 'app_footer.dart';

/// Max content width on large screens.
const double kMaxContentWidth = 1200;

/// Standard page body: centered, padded, scrollable, optional footer.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child, this.showFooter = true});

  final Widget child;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final padding = context.isMobile ? AppSpacing.md : AppSpacing.lg;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: Padding(padding: EdgeInsets.all(padding), child: child),
            ),
          ),
          if (showFooter) const AppFooter(),
        ],
      ),
    );
  }
}
