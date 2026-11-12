import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/favorites_repository.dart';

/// Stores favorites at `users/{uid}/favorites/{listingId}`.
class FirestoreFavoritesRepository implements FavoritesRepository {
  FirestoreFavoritesRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  @override
  Stream<Set<String>> watchIds(String uid, {int limit = 200}) => _col(uid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  @override
  Future<void> add(String uid, String listingId) => _col(uid)
      .doc(listingId)
      .set({'listingId': listingId, 'createdAt': FieldValue.serverTimestamp()});

  @override
  Future<void> remove(String uid, String listingId) =>
      _col(uid).doc(listingId).delete();
}
