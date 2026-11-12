import '../entities/category.dart';

/// Source of category data (Firestore in production).
abstract interface class CategoryRepository {
  /// All active categories and subcategories, ordered by [Category.order].
  Future<List<Category>> getAll();

  /// Admin: create or update a category.
  Future<void> upsert(Category category);

  /// Admin: deactivate (soft delete) a category.
  Future<void> deactivate(String categoryId);
}
