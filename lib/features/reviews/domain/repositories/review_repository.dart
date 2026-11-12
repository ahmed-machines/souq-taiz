import '../../../../core/result/result.dart';
import '../entities/review.dart';

abstract interface class ReviewRepository {
  /// Approved reviews for a seller, newest first.
  Future<List<Review>> getApprovedForSeller(String sellerId, {int limit = 20});

  /// Submits a review as `pending`. Fails validation for self-reviews and
  /// when the reviewer already reviewed this seller (one per pair).
  Future<Result<void>> submit({
    required String sellerId,
    required String reviewerId,
    required String reviewerName,
    required int rating,
    required String text,
  });
}
