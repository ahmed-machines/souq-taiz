import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../../core/validators/validators.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

/// Reviews at `reviews/{sellerId_reviewerId}`. The deterministic id makes
/// duplicate reviews impossible; rules forbid updates by the reviewer.
class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('reviews');

  @override
  Future<List<Review>> getApprovedForSeller(
    String sellerId, {
    int limit = 20,
  }) async {
    final snap = await _col
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: ReviewStatus.approved.value)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return Review(
        id: d.id,
        sellerId: sellerId,
        reviewerId: (m['reviewerId'] ?? '') as String,
        reviewerName: (m['reviewerName'] ?? '') as String,
        rating: (m['rating'] ?? 0) as int,
        text: (m['text'] ?? '') as String,
        status: ReviewStatus.approved,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<Result<void>> submit({
    required String sellerId,
    required String reviewerId,
    required String reviewerName,
    required int rating,
    required String text,
  }) async {
    if (sellerId == reviewerId ||
        Validators.rating(rating) != null ||
        text.trim().length > 500) {
      return const Err(Failure(FailureType.validation));
    }
    try {
      // `set` on an existing id would be an update, which rules reject.
      await _col.doc('${sellerId}_$reviewerId').set({
        'sellerId': sellerId,
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'rating': rating,
        'text': text.trim(),
        'status': ReviewStatus.pending.value,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }
}
