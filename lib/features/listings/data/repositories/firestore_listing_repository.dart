import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../models/listing_mapper.dart';

/// Firestore implementation of [ListingRepository].
class FirestoreListingRepository implements ListingRepository {
  FirestoreListingRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('listings');

  @override
  String newId() => _col.doc().id;

  @override
  Future<Listing?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? ListingMapper.fromDoc(doc) : null;
  }

  @override
  Future<void> create(Listing listing) =>
      _col.doc(listing.id).set(ListingMapper.toCreateMap(listing));

  @override
  Future<void> update(Listing listing) =>
      _col.doc(listing.id).update(ListingMapper.toUpdateMap(listing));

  @override
  Future<void> setOwnerStatus(String id, ListingStatus status) =>
      _col.doc(id).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<ListingPage> getByOwner(
    String ownerId, {
    ListingStatus? status,
    Object? cursor,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> q = _col.where('ownerId', isEqualTo: ownerId);
    if (status != null) q = q.where('status', isEqualTo: status.value);
    q = q.orderBy('createdAt', descending: true).limit(limit);
    if (cursor is DocumentSnapshot) q = q.startAfterDocument(cursor);
    final snap = await q.get();
    return ListingPage(
      items: snap.docs.map(ListingMapper.fromDoc).toList(),
      cursor: snap.docs.isEmpty ? null : snap.docs.last,
      hasMore: snap.docs.length == limit,
    );
  }

  @override
  Future<List<Listing>> getRelated(Listing listing, {int limit = 6}) async {
    final snap = await _col
        .where('status', isEqualTo: ListingStatus.published.value)
        .where('categoryId', isEqualTo: listing.categoryId)
        .orderBy('createdAt', descending: true)
        .limit(limit + 1)
        .get();
    return snap.docs
        .where((d) => d.id != listing.id)
        .take(limit)
        .map(ListingMapper.fromDoc)
        .toList();
  }

  @override
  Future<Map<ListingStatus, int>> countByStatus(String ownerId) async {
    final counts = <ListingStatus, int>{};
    for (final s in ListingStatus.values) {
      final agg = await _col
          .where('ownerId', isEqualTo: ownerId)
          .where('status', isEqualTo: s.value)
          .count()
          .get();
      counts[s] = agg.count ?? 0;
    }
    return counts;
  }
}
