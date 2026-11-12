# Souq Taiz | سوق تعز

> **سوقك المحلي.. كل شيء أقرب إليك**  
> A modern local marketplace for Taiz, Yemen.

---

## Overview

Souq Taiz is a production-quality Flutter Web marketplace platform connecting buyers and sellers in Taiz, Yemen. It is Arabic-first with full RTL support, bilingual (AR/EN), and built on Firebase.

| Feature | Status |
|---|---|
| Arabic/English with RTL | ✅ |
| Email + Google Auth | ✅ |
| Listings CRUD + Image Upload | ✅ |
| Search & Filters | ✅ |
| Favorites | ✅ |
| Buyer–Seller Messaging | ✅ |
| Seller Dashboard | ✅ |
| Reviews & Ratings | ✅ |
| Push Notifications | ✅ |
| Admin Panel | ✅ |
| Demo Mode (no Firebase needed) | ✅ |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter Web, Dart, Material 3 |
| State | Riverpod |
| Navigation | GoRouter |
| Backend | Firebase Auth, Firestore, Storage, Functions |
| Localization | flutter_gen_l10n (AR + EN) |
| Testing | flutter_test, fake_cloud_firestore |

---

## Quick Start

### Demo Mode (No Firebase)

```bash
git clone https://github.com/YOUR_ORG/souq-taiz.git
cd souq-taiz
flutter pub get
flutter run -d chrome
```

The app runs with in-memory mock Arabic data. No Firebase account needed.

### With Firebase

See [`docs/setup/firebase-setup.md`](docs/setup/firebase-setup.md) for full instructions.

---

## Project Structure

```
lib/
  main.dart
  bootstrap/          Firebase + app initialization
  app/                Router, theme, localization
  core/               Validators, utils, shared widgets
  shared/             Cross-feature models, mock repos
  features/           Feature modules
    authentication/
    home/
    categories/
    listings/
    search/
    favorites/
    seller_dashboard/
    messaging/
    reviews/
    notifications/
    user_profile/
    admin/
firebase/             Security rules & indexes
functions/            Cloud Functions (TypeScript)
tool/                 Code generators & seed scripts
docs/                 Architecture, database, setup guides
test/                 Unit, widget & integration tests
```

---

## Development

```bash
# Install dependencies
flutter pub get

# Run tests
flutter test --no-pub

# Static analysis
flutter analyze --no-pub

# Regenerate localizations (after editing ARB files)
python tool/gen_arb.py
flutter gen-l10n

# Build for production
flutter build web --release
```

See [`docs/setup/local-development.md`](docs/setup/local-development.md) for detailed setup.

---

## Architecture

Clean architecture with feature-first organization. See [`docs/architecture/decisions.md`](docs/architecture/decisions.md) for all Architecture Decision Records.

Key principles:
- Widgets never talk to Firebase directly
- All Firebase access goes through Repository interfaces
- Business logic lives in use cases, not widgets
- Route guards are UX-only; authorization is enforced server-side

---

## Documentation

| Document | Description |
|---|---|
| [Firebase Setup](docs/setup/firebase-setup.md) | Create Firebase project and deploy |
| [Local Development](docs/setup/local-development.md) | Dev environment setup |
| [Production Deployment](docs/deployment/production-deployment.md) | Deploy to production |
| [Firestore Schema](docs/database/firestore-schema.md) | Collections, fields, indexes |
| [Security Rules](docs/security/security-rules.md) | Rule logic and rationale |
| [Architecture Decisions](docs/architecture/decisions.md) | ADRs (why we chose what we did) |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Write tests for your changes
4. Ensure `flutter test --no-pub` passes
5. Ensure `flutter analyze --no-pub` is clean
6. Submit a pull request

---

## License

MIT License — see [LICENSE](LICENSE)

---

## About

Built for the Taiz community. سوق تعز — connecting local buyers and sellers.
