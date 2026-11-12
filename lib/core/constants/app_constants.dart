import 'dart:ui';

/// App-wide constants that are not design tokens.
abstract final class AppConstants {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');
  static const Locale defaultLocale = arabic;
  static const List<Locale> supportedLocales = [arabic, english];

  /// Default currency; more currencies can be added later.
  static const String defaultCurrency = 'YER';
}
