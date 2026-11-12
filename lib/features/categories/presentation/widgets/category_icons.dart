import 'package:flutter/material.dart';

/// Maps category `iconKey` values (stored in Firestore) to Material icons.
abstract final class CategoryIcons {
  static const Map<String, IconData> _icons = {
    'car': Icons.directions_car_outlined,
    'home': Icons.home_work_outlined,
    'phone': Icons.smartphone,
    'computer': Icons.laptop_mac,
    'chair': Icons.chair_outlined,
    'fashion': Icons.checkroom,
    'work': Icons.work_outline,
    'build': Icons.build_outlined,
    'pets': Icons.pets,
    'category': Icons.category_outlined,
  };

  static IconData of(String key) => _icons[key] ?? Icons.category_outlined;
}
