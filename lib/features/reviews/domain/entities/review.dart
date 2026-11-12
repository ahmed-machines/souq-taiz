import 'package:flutter/foundation.dart';

enum ReviewStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ReviewStatus(this.value);
  final String value;

  static ReviewStatus parse(String? v) => ReviewStatus.values.firstWhere(
    (s) => s.value == v,
    orElse: () => ReviewStatus.pending,
  );
}

@immutable
class Review {
  const Review({
    required this.id,
    required this.sellerId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.text,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String sellerId;
  final String reviewerId;
  final String reviewerName;
  final int rating;
  final String text;
  final ReviewStatus status;
  final DateTime createdAt;
}
