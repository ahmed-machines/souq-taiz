# Architecture Decision Records

## ADR-001: Feature-First + Clean Architecture

**Status:** Accepted  
**Date:** 2026-11

### Context
Flutter applications can be organized by layer (all repositories together, all pages together) or by feature. The team needs a structure that scales as new features are added without creating circular dependencies.

### Decision
Use **feature-first** organization with **clean architecture layers** within each feature:

```
features/
  <feature_name>/
    data/
      datasources/     # Firebase/API access
      models/          # JSON ↔ Dart mapping
      repositories/    # Concrete implementations
    domain/
      entities/        # Pure Dart business objects
      repositories/    # Abstract interfaces
      usecases/        # Business operation coordinators
    presentation/
      controllers/     # Riverpod providers/notifiers
      pages/           # Full-screen widgets
      widgets/         # Composable UI parts
```

### Consequences
- Features are self-contained and independently deployable
- Onboarding new engineers: edit one feature without touching others
- Testability: mock domain repositories independently of Firebase
- Trade-off: more files per feature than a flat structure

---

## ADR-002: Riverpod for State Management

**Status:** Accepted  
**Date:** 2026-11

### Context
Flutter has many state management options: BLoC, Provider, GetX, MobX, Riverpod.

### Decision
Use **Riverpod** (flutter_riverpod) for:
- Dependency injection (all repository providers)
- Reactive state (AsyncNotifier, StreamProvider)
- Global state access without BuildContext propagation

### Rationale
- Compile-time safety (no string-based lookups)
- Native async support with `AsyncValue`
- Easy testing via `ProviderScope` overrides
- No Flutter widget tree dependency for access

### Consequences
- Learning curve for Riverpod-specific patterns (ref.watch vs ref.read)
- All providers defined close to their feature (not in a single global file)

---

## ADR-003: GoRouter for Navigation

**Status:** Accepted  
**Date:** 2026-11

### Context
Flutter Web requires URL-based routing for deep linking and browser history.

### Decision
Use **GoRouter** with:
- Named routes (string constants in `RouteNames`)
- `redirect` callbacks for auth/role guards
- `ShellRoute` for layouts shared across routes (admin shell, public shell)

### Key Rule
Route guards are UX-only conveniences. All authorization is enforced server-side via Firestore Security Rules and Cloud Functions. A client-side bypass does not grant actual data access.

---

## ADR-004: Demo Mode Architecture

**Status:** Accepted  
**Date:** 2026-11

### Context
Developers need to run the full UI without Firebase credentials. QA needs a consistent seed dataset.

### Decision
`FirebaseBootstrap` checks for `google-services.json` / Firebase web config at startup. If absent:
- `firebaseStatusProvider` returns `FirebaseStatus.notConfigured`
- All repository providers switch to `Mock*Repository` implementations
- A demo banner is shown at the top of the app

The switch happens in `repository_providers.dart` via a single conditional:

```dart
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ref.watch(firebaseReadyProvider)
      ? FirestoreListingRepository(ref.watch(firestoreProvider))
      : MockListingRepository();
});
```

### Consequences
- Zero extra environment setup for new contributors
- Mock data is realistic Arabic marketplace content
- Production and demo paths share identical interfaces (no code divergence)

---

## ADR-005: Arabic-First, RTL-Default

**Status:** Accepted  
**Date:** 2026-11

### Decision
- Default locale: Arabic (`ar`)
- Text direction: RTL
- Language toggle persists via `localeProvider` (Riverpod)
- All ARB keys exist in both `app_ar.arb` and `app_en.arb`
- ARB files are written by `tool/gen_arb.py` (Python), not PowerShell, to prevent UTF-8 corruption

### Conventions
- Arabic strings use standard Egyptian/Gulf Arabic where MSA is ambiguous
- Currency: Yemeni Rial (YER) formatted by `PriceFormatter`
- Phone validation: Yemeni mobile patterns (`Validators.phone`)

---

## ADR-006: Search Abstraction

**Status:** Accepted  
**Date:** 2026-11

### Context
Cloud Firestore does not support full-text search. Options include Algolia, Typesense, Elasticsearch, or client-side filtering.

### Decision
Search is behind a `ListingSearchService` interface:

```dart
abstract interface class ListingSearchService {
  Future<Result<ListingPage>> search(SearchQuery query, {DocumentSnapshot? cursor});
}
```

The current implementation (`FirestoreSearchService`) uses:
1. Firestore queries for category, location, price range, and featured filters
2. Client-side `QueryMatcher` for keyword matching within result sets

A future implementation can plug in Algolia or Typesense behind the same interface without touching the presentation layer.

### Consequences
- Current search is limited to prefix/token matching on stored keyword arrays
- Full-text fuzzy search requires a future service integration
- The swap is a one-line change in `repository_providers.dart`

---

## ADR-007: Soft-Delete Only for Listings

**Status:** Accepted  
**Date:** 2026-11

### Decision
Listings are never hard-deleted from Firestore. Instead, `status` transitions to:
- `archived` — user deleted their listing
- `rejected` — admin rejected
- `sold` — marked sold by owner

### Rationale
- Preserves audit trail
- Allows admin review of moderated content
- Prevents dangling references in messaging conversations
- Storage images are cleaned up asynchronously by a Cloud Function

---

## ADR-008: Image Handling Strategy

**Status:** Accepted  
**Date:** 2026-11

### Decision
- Max 8 images per listing, max 5 MB per image
- Types: JPG, PNG, WebP only
- Images stored in Firebase Storage at `listings/{listingId}/{imageIndex}_{timestamp}`
- `SubmitListing` use case handles: upload new local images in order → keep existing remote URLs
- `ListingImage` is a sealed class: `LocalImage` (picked file) | `RemoteImage` (existing URL)
- Cover image = first in the list (`imageUrls.first`)

### Consequences
- Reorder drag-and-drop changes the array order → cover image changes automatically
- Orphaned images (listing deleted) are cleaned up by `onListingDeleted` Cloud Function (future work)

---

## ADR-009: Security Architecture

**Status:** Accepted  
**Date:** 2026-11

### Layers
1. **Client route guards** — redirect unauthenticated users (UX only)
2. **Firestore Security Rules** — enforced by Firebase servers, cannot be bypassed by clients
3. **Cloud Functions** — admin operations use Firebase Admin SDK with full privileges
4. **Role validation** — `AppUser.role` read from Firestore server-side; client cannot self-assign admin role

### Key Rules
- Users can only write to their own documents (`request.auth.uid == resource.data.ownerId`)
- Listings created by clients have `isFeatured=false` and `viewCount=0` enforced in rules
- Admin functions (`setUserRole`, `setFeatured`, `resolveReport`) are callable Cloud Functions that verify the caller has `role == 'admin'` server-side

---

## ADR-010: Testing Strategy

**Status:** Accepted  
**Date:** 2026-11

### Pyramid
| Layer | Coverage | Tools |
|---|---|---|
| Unit tests | Validators, search domain, route guards, use cases | `flutter_test`, pure Dart |
| Widget tests | Standalone form widgets, listing card, search filters | `flutter_test`, `testApp` helper |
| Integration tests | Browse/search/favorite flows | Mock repositories, GoRouter |
| Repository tests | Firestore repository query logic | `fake_cloud_firestore` |

### Constraints
- `fake_cloud_firestore` does not support `startAfterDocument` for second-page pagination in composite queries. Second-page tests use `MockListingRepository` instead.
- Widget tests for form validation use **standalone minimal form widgets** (not full page widgets) to avoid nested-scroll issues with `AuthFormCard` + `PageContainer`.
- Arabic string literals in tests are compared via exact `find.text()` match — the generated localization files must be regenerated whenever ARB files change.
