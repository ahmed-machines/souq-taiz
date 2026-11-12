import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../domain/entities/review.dart';

final sellerReviewsProvider = FutureProvider.family<List<Review>, String>(
  (ref, sellerId) =>
      ref.watch(reviewRepositoryProvider).getApprovedForSeller(sellerId),
);
