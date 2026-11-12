# Architecture Overview

Feature-first Clean Architecture with Riverpod.

- `lib/bootstrap` – startup and Firebase initialization (from `--dart-define`).
- `lib/app` – root widget, router, theme, localization (ar primary / en secondary, RTL/LTR follows locale).
- `lib/core` – cross-cutting code (Result/Failure, logging, constants). No feature imports.
- `lib/shared` – shared models/providers/widgets (added when first needed).
- `lib/features/<feature>/{data,domain,presentation}` – each feature self-contained; widgets never touch Firebase, only repositories via providers.

**Decision:** feature folders are created when the feature is implemented (no empty folders). `application` layer is represented by Riverpod controllers in `presentation/controllers` and use cases in `domain/usecases`.

**Decision:** `freezed`/`json_serializable`/`build_runner` are deferred until Phase 2+ when models exist.

Status: Phase 1 only (foundation + placeholder home).
