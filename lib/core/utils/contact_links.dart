/// Builds safe external contact URLs from validated input.
abstract final class ContactLinks {
  static final RegExp _allowedChars = RegExp(r'^[\d\s\-+()]+$');
  static final RegExp _yemenMobile = RegExp(r'^(?:967|00967|0)?(7\d{8})$');

  /// Normalizes a Yemeni number to international digits (967XXXXXXXXX), or
  /// returns null when it contains unexpected characters or is not a valid
  /// mobile number.
  static String? normalizeYemenPhone(String raw) {
    final trimmed = raw.trim();
    if (!_allowedChars.hasMatch(trimmed)) return null;
    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    final match = _yemenMobile.firstMatch(digits);
    return match == null ? null : '967${match.group(1)}';
  }

  /// WhatsApp click-to-chat URI. Text is percent-encoded by [Uri].
  static Uri? whatsApp(String rawPhone, {String? message}) {
    final phone = normalizeYemenPhone(rawPhone);
    if (phone == null) return null;
    final hasMessage = message != null && message.isNotEmpty;
    return Uri.https('wa.me', '/$phone', hasMessage ? {'text': message} : null);
  }

  static Uri? phoneCall(String rawPhone) {
    final phone = normalizeYemenPhone(rawPhone);
    return phone == null ? null : Uri(scheme: 'tel', path: '+$phone');
  }
}
