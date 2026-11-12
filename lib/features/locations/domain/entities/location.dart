import 'package:flutter/foundation.dart';

import '../../../categories/domain/entities/category.dart';

/// A location. Hierarchy: governorate (no parent) -> district/area (parent).
/// Data is admin-maintained; no neighborhood list is hardcoded in the app.
@immutable
class Location {
  const Location({
    required this.id,
    required this.name,
    this.parentId,
    this.isActive = true,
  });

  final String id;
  final LocalizedName name;
  final String? parentId;
  final bool isActive;
}
