/// Validation error codes. UI maps them to localized messages so validators
/// stay free of presentation concerns.
enum ValidationError {
  required,
  invalidEmail,
  weakPassword,
  passwordMismatch,
  invalidPhone,
  tooShort,
  tooLong,
  invalidPrice,
  priceTooHigh,
  tooManyImages,
  noImages,
  invalidImageType,
  imageTooLarge,
  invalidRating,
}

/// Pure, side-effect free validators. Each returns `null` when valid.
abstract final class Validators {
  static const int minPasswordLength = 8;
  static const int titleMin = 5;
  static const int titleMax = 100;
  static const int descriptionMin = 10;
  static const int descriptionMax = 3000;
  static const int maxPrice = 1000000000000;
  static const int maxImages = 8;
  static const int maxImageBytes = 5 * 1024 * 1024;
  static const Set<String> allowedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  // Yemeni mobile numbers: optional +967/00967 then 9 digits starting with 7.
  static final RegExp _yemenPhone = RegExp(r'^(?:\+?967|00967|0)?7\d{8}$');

  static ValidationError? required(String? v) =>
      (v == null || v.trim().isEmpty) ? ValidationError.required : null;

  static ValidationError? email(String? v) {
    final r = required(v);
    if (r != null) return r;
    return _email.hasMatch(v!.trim()) ? null : ValidationError.invalidEmail;
  }

  static ValidationError? password(String? v) {
    final r = required(v);
    if (r != null) return r;
    final hasLetter = RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(v!);
    final hasDigit = RegExp(r'\d').hasMatch(v);
    return (v.length >= minPasswordLength && hasLetter && hasDigit)
        ? null
        : ValidationError.weakPassword;
  }

  static ValidationError? confirmPassword(String? v, String? original) =>
      v == original ? null : ValidationError.passwordMismatch;

  static ValidationError? phone(String? v) {
    final r = required(v);
    if (r != null) return r;
    final cleaned = v!.replaceAll(RegExp(r'[\s\-]'), '');
    return _yemenPhone.hasMatch(cleaned) ? null : ValidationError.invalidPhone;
  }

  static ValidationError? title(String? v) => _length(v, titleMin, titleMax);

  static ValidationError? description(String? v) =>
      _length(v, descriptionMin, descriptionMax);

  static ValidationError? _length(String? v, int min, int max) {
    final r = required(v);
    if (r != null) return r;
    final len = v!.trim().length;
    if (len < min) return ValidationError.tooShort;
    if (len > max) return ValidationError.tooLong;
    return null;
  }

  static ValidationError? price(num? v) {
    if (v == null || v <= 0) return ValidationError.invalidPrice;
    if (v > maxPrice) return ValidationError.priceTooHigh;
    return null;
  }

  static ValidationError? rating(int? v) =>
      (v == null || v < 1 || v > 5) ? ValidationError.invalidRating : null;

  /// Validates a picked image by file name and size.
  static ValidationError? image({
    required String fileName,
    required int bytes,
  }) {
    final dot = fileName.lastIndexOf('.');
    final ext = dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
    if (!allowedImageExtensions.contains(ext)) {
      return ValidationError.invalidImageType;
    }
    if (bytes > maxImageBytes) return ValidationError.imageTooLarge;
    return null;
  }
}
