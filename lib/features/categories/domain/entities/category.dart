import 'package:flutter/foundation.dart';

/// Localized name pair (Arabic primary, English secondary).
@immutable
class LocalizedName {
  const LocalizedName({required this.ar, required this.en});

  factory LocalizedName.fromMap(Map<String, dynamic> map) => LocalizedName(
    ar: (map['nameAr'] ?? '') as String,
    en: (map['nameEn'] ?? '') as String,
  );

  final String ar;
  final String en;

  /// Returns the name for [languageCode], falling back to Arabic.
  String of(String languageCode) =>
      languageCode == 'en' && en.isNotEmpty ? en : ar;
}

/// A category or subcategory. Subcategories have a non-null [parentId].
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.order,
    this.parentId,
    this.iconKey = 'category',
    this.isActive = true,
  });

  final String id;
  final LocalizedName name;
  final int order;
  final String? parentId;

  /// Key mapped to an icon in the presentation layer (keeps domain UI-free).
  final String iconKey;
  final bool isActive;

  bool get isSubcategory => parentId != null;
}
