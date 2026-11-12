import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formats prices. Currency symbols are looked up so more can be added later.
abstract final class PriceFormatter {
  static const Map<String, String> _symbols = {'YER': 'ر.ي'};

  static String format(
    num amount, {
    String currency = AppConstants.defaultCurrency,
    String? locale,
  }) {
    final number = NumberFormat.decimalPattern(locale).format(amount);
    final symbol = (locale == 'en' ? currency : _symbols[currency]) ?? currency;
    return '$number $symbol';
  }
}
