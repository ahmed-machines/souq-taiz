import 'package:flutter/widgets.dart';

import '../../app/theme/app_spacing.dart';

/// Responsive helpers based on [AppBreakpoints].
extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;
  bool get isMobile => _width < AppBreakpoints.tablet;
  bool get isDesktop => _width >= AppBreakpoints.desktop;

  /// Number of grid columns suited to the current width.
  int get gridColumns => isDesktop ? 4 : (isMobile ? 2 : 3);
}
