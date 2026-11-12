# Local Development Guide

## Prerequisites

| Tool | Minimum Version | Install |
|---|---|---|
| Flutter SDK | 3.22 (stable) | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.4 | Included with Flutter |
| Node.js | 18 LTS | [nodejs.org](https://nodejs.org) |
| npm | 9 | Included with Node.js |
| Firebase CLI | 13 | `npm install -g firebase-tools` |
| Git | 2.40 | [git-scm.com](https://git-scm.com) |

---

## 1. Clone the Repository

```bash
git clone https://github.com/YOUR_ORG/souq-taiz.git
cd souq-taiz
```

---

## 2. Install Flutter Dependencies

```bash
flutter pub get
```

---

## 3. Install Cloud Functions Dependencies

```bash
cd functions
npm install
npm run build      # Compile TypeScript → JavaScript
cd ..
```

---

## 4. Running in Demo Mode (No Firebase Required)

The app detects missing Firebase config and runs with **in-memory mock repositories**.

```bash
flutter run -d chrome
```

A demo banner appears at the top. All features work with pre-seeded Arabic sample data.

> [!TIP]
> Demo mode is perfect for UI development and running all tests locally without Firebase.

---

## 5. Running with a Real Firebase Project

1. Complete `docs/setup/firebase-setup.md` first
2. Add your `web/firebase-config.js`
3. Run:

```bash
flutter run -d chrome --dart-define=ENV=production
```

---

## 6. Running with Firebase Local Emulator Suite

The emulator suite lets you develop against local Firestore, Auth, Storage and Functions without touching the live project.

### Start emulators

```bash
firebase emulators:start --import ./emulator-data --export-on-exit ./emulator-data
```

Emulator ports:
| Service | Port |
|---|---|
| Auth | 9099 |
| Firestore | 8080 |
| Storage | 9199 |
| Functions | 5001 |
| Emulator UI | 4000 |

### Connect Flutter to emulators

In `lib/bootstrap/firebase_bootstrap.dart`, uncomment the emulator connection block during local dev:

```dart
// Emulator connections (dev only — never commit uncommented)
// FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
// FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
// FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
```

> [!CAUTION]
> Never commit emulator connection code uncommented. Use `--dart-define=USE_EMULATORS=true` and conditional logic tied to that flag instead.

---

## 7. Code Generation

If you modify ARB localization files:

```bash
python tool/gen_arb.py      # regenerates app_ar.arb / app_en.arb
flutter gen-l10n            # regenerates lib/app/localization/generated/
```

> [!WARNING]
> Always use the Python script to write ARB files. PowerShell corrupts Arabic characters (UTF-8 → Windows-1252).

---

## 8. Running Tests

```bash
# All tests
flutter test --no-pub

# Single suite
flutter test test/unit/validators_test.dart --no-pub

# With coverage
flutter test --no-pub --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 9. Static Analysis

```bash
flutter analyze --no-pub
dart format --set-exit-if-changed lib/ test/
```

Both must be clean before merging any PR.

---

## 10. Build for Production

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## Project Layout Quick Reference

```
lib/
  main.dart               Entry point
  bootstrap/              Firebase + app initialization
  app/                    Router, theme, localization
  core/                   Shared utilities, validators, widgets
  shared/                 Cross-feature models, providers, mock data
  features/               Feature modules (auth, home, listings…)
test/
  unit/                   Pure Dart unit tests
  widget/                 Flutter widget tests
  integration/            End-to-end flow tests (mock repos)
firebase/
  firestore.rules         Firestore Security Rules
  firestore.indexes.json  Composite indexes
  storage.rules           Firebase Storage rules
functions/
  src/index.ts            Cloud Functions (TypeScript)
tool/
  gen_arb.py              ARB file generator
  gen_indexes.js          Composite index generator
  seed_firestore.js       Initial data seed script
docs/
  architecture/           Architecture decisions
  database/               Schema and indexes docs
  setup/                  Firebase and dev setup (this folder)
  deployment/             Production deployment guide
```
