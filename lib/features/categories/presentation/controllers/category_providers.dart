import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../domain/entities/category.dart';

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).getAll(),
);

/// Top-level categories ordered for display.
final topCategoriesProvider = Provider<List<Category>>((ref) {
  final all = ref.watch(categoriesProvider).value ?? const <Category>[];
  return all.where((c) => !c.isSubcategory).toList();
});

final subcategoriesProvider = Provider.family<List<Category>, String?>((
  ref,
  parentId,
) {
  if (parentId == null) return const [];
  final all = ref.watch(categoriesProvider).value ?? const <Category>[];
  return all.where((c) => c.parentId == parentId).toList();
});
