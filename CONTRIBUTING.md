# Contributing

- Branches: `main` (stable), `develop`, `feature/<name>`, `fix/<name>`.
- Conventional commits: `feat(auth): ...`, `fix(storage): ...`, `test(...)`, `refactor(...)`, `docs(...)`.
- Before a PR: `dart format .`, `flutter analyze`, `flutter test` must pass.
- No business logic in widgets; no Firebase calls outside data layer; no secrets in commits.
