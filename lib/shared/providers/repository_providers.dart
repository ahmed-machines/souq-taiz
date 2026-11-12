import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/admin/data/repositories/firebase_admin_repository.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/authentication/data/repositories/firebase_auth_repository.dart';
import '../../features/authentication/data/repositories/unconfigured_auth_repository.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/categories/data/repositories/firestore_category_repository.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/favorites/data/repositories/firestore_favorites_repository.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/listings/data/repositories/firebase_listing_image_uploader.dart';
import '../../features/listings/data/repositories/firestore_listing_repository.dart';
import '../../features/listings/domain/repositories/listing_repository.dart';
import '../../features/listings/domain/usecases/listing_input.dart';
import '../../features/listings/domain/usecases/submit_listing.dart';
import '../../features/locations/data/repositories/firestore_location_repository.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/messaging/data/repositories/firestore_messaging_repository.dart';
import '../../features/messaging/domain/repositories/messaging_repository.dart';
import '../../features/notifications/data/repositories/firestore_notification_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/reviews/data/repositories/firestore_review_repository.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/search/data/firestore_search_service.dart';
import '../../features/search/domain/search_query.dart';
import '../mock/mock_repositories.dart';
import 'firebase_providers.dart';

// Dependency-injection wiring. Browse features (categories, locations,
// listings, search) fall back to clearly-labelled demo data when Firebase is
// not configured; every other feature requires Firebase.

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirestoreCategoryRepository(ref.watch(firestoreProvider))
      : MockCategoryRepository(),
);

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirestoreLocationRepository(ref.watch(firestoreProvider))
      : MockLocationRepository(),
);

final _mockListingsProvider = Provider<MockListingRepository>(
  (ref) => MockListingRepository(),
);

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirestoreListingRepository(ref.watch(firestoreProvider))
      : ref.watch(_mockListingsProvider),
);

final searchServiceProvider = Provider<ListingSearchService>(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirestoreSearchService(ref.watch(firestoreProvider))
      : ref.watch(_mockListingsProvider),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirebaseAuthRepository(
          ref.watch(firebaseAuthProvider),
          ref.watch(firestoreProvider),
        )
      : UnconfiguredAuthRepository(),
);

final listingImageUploaderProvider = Provider<ListingImageUploader>(
  (ref) => FirebaseListingImageUploader(ref.watch(firebaseStorageProvider)),
);

final submitListingProvider = Provider<SubmitListing>(
  (ref) => SubmitListing(
    ref.watch(listingRepositoryProvider),
    ref.watch(listingImageUploaderProvider),
  ),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FirestoreFavoritesRepository(ref.watch(firestoreProvider)),
);

final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => FirestoreMessagingRepository(ref.watch(firestoreProvider)),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FirestoreReviewRepository(ref.watch(firestoreProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirestoreNotificationRepository(ref.watch(firestoreProvider)),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirebaseAdminRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  ),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => FirestoreReportRepository(ref.watch(firestoreProvider)),
);
