import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

/// Firestore-backed categories (`categories` collection).
class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('categories');

  @override
  Future<List<Category>> getAll() async {
    final snap = await _col
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> upsert(Category c) => _col.doc(c.id).set(toMap(c));

  @override
  Future<void> deactivate(String categoryId) =>
      _col.doc(categoryId).update({'isActive': false});

  static Category fromMap(String id, Map<String, dynamic> m) => Category(
    id: id,
    name: LocalizedName.fromMap(m),
    order: (m['order'] ?? 0) as int,
    parentId: m['parentId'] as String?,
    iconKey: (m['iconKey'] ?? 'category') as String,
    isActive: (m['isActive'] ?? true) as bool,
  );

  static Map<String, dynamic> toMap(Category c) => {
    'nameAr': c.name.ar,
    'nameEn': c.name.en,
    'order': c.order,
    'parentId': c.parentId,
    'iconKey': c.iconKey,
    'isActive': c.isActive,
  };
}
