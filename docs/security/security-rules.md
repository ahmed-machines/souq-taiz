# Security rules and trusted server logic

Files: `firebase/firestore.rules`, `firebase/storage.rules`, `functions/src/index.ts`.

## Principles

* **Default deny.** Anything not matched is rejected.
* **Roles are never trusted from the client.** Rules read `users/{uid}.role/status` from Firestore. Clients can only create their own profile as `buyer`/`active`; `role` and `status` are written only by Cloud Functions (Admin SDK bypasses rules).
* **Client route guards are UX only** (`RouteGuards`). The admin UI is unusable without real privileges because every admin read/write is rejected server-side.
* **Suspended accounts** are blocked from every write (`isActive()`), and their Firebase Auth user is disabled by `setUserSuspended`.

## Firestore summary

| Resource | Rule highlights |
|---|---|
| `users` | owner/admin read; create only as `buyer`/`active` with allowed keys; owner may change only `displayName`, `phone`; no delete |
| `listings` | public read only when `published` (owner/admin otherwise); create must be `draft`/`pending_review`, `isFeatured=false`, `viewCount=0`, `createdAt==request.time`, validated title/description/price/images/phone; owner updates cannot touch `ownerId`, `createdAt`, `isFeatured`, `viewCount`, `rejectionReason`; status transitions whitelisted (owners can never publish/reject); content edits force review; no delete |
| `conversations`/`messages` | participants only; creator must be buyer; the other participant must be the listing owner; only recipient can set `readAt`; sender must equal `auth.uid`; text ≤ 1000 |
| `reviews` | create requires verified email, not self, id = `seller_reviewer` (one per pair), rating 1–5, `pending`; reviewers cannot update; only admins may change `status` |
| `reports` | create-only for users (id = `listing_reporter`); admins read; resolved via function |
| `admin_logs` | admins read; no client writes |
| `categories`/`locations` | public read; admin write |

## Cloud Functions (callable, region default)

`moderateListing`, `setFeatured`, `setUserSuspended`, `setUserRole` (super admin only), `resolveReport`. Each re-reads the caller's role from Firestore, validates inputs, performs the change, writes a notification where relevant and appends to `admin_logs`. Triggers: `onMessageCreated` (notification + rate limit of 20 messages/minute/sender).

Category/location edits are written directly by admins (rules-checked) and are **not** in the audit log — a known gap.

## Storage

`listings/{ownerId}/{listingId}/{file}`: public read; create only by the owner with an active account, `image/(jpeg|png|webp)`, < 5 MB; delete by owner. Everything else denied.

## Abuse controls

Message rate limit (function), one report per pair, one review per pair, size/length limits in rules. **Not implemented:** Firebase App Check (enable per `docs/deployment/production-deployment.md`), per-user listing quotas, login throttling beyond Firebase Auth defaults.

## Testing the rules

`firebase/rules-tests` contains emulator-based tests: `npm --prefix firebase/rules-tests test` (see `docs/setup/local-development.md`).
