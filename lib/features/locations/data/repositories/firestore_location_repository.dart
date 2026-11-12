import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

/// Firestore-backed locations (`locations` collection).
class FirestoreLocationRepository implements LocationRepository {
  FirestoreLocationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('locations');

  @override
  Future<List<Location>> getAll() async {
    final snap = await _col.where('isActive', isEqualTo: true).get();
    return snap.docs
        .map(
          (d) => Location(
            id: d.id,
            name: LocalizedName.fromMap(d.data()),
            parentId: d.data()['parentId'] as String?,
          ),
        )
        .toList();
  }

  @override
  Future<void> upsert(Location l) => _col.doc(l.id).set({
    'nameAr': l.name.ar,
    'nameEn': l.name.en,
    'parentId': l.parentId,
    'isActive': l.isActive,
  });

  @override
  Future<void> deactivate(String locationId) =>
      _col.doc(locationId).update({'isActive': false});
}
