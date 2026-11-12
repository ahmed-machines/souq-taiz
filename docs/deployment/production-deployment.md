# Production Deployment Guide

## Overview

Souq Taiz is deployed as a Flutter Web app on **Firebase Hosting**, with:
- **Cloud Firestore** for data
- **Firebase Storage** for images
- **Cloud Functions** for server-side logic
- **Firebase Authentication** for identity

---

## Pre-Deployment Checklist

- [ ] All tests pass: `flutter test --no-pub`
- [ ] No analyzer issues: `flutter analyze --no-pub`
- [ ] `web/firebase-config.js` has production credentials
- [ ] Firestore rules reviewed and deployed
- [ ] Storage rules reviewed and deployed
- [ ] Cloud Functions compiled: `cd functions && npm run build`
- [ ] Composite indexes deployed and built
- [ ] `.gitignore` excludes `web/firebase-config.js`

---

## 1. Environment Variables

| Variable | Where Set | Purpose |
|---|---|---|
| Firebase config | `web/firebase-config.js` | Firebase project credentials |
| `ENV` | `--dart-define` flag | `production` / `development` |

Never hardcode credentials. Use `.firebaserc` to switch between Firebase projects:

```bash
firebase use production     # points to live project
firebase use staging        # points to staging project
```

---

## 2. Build Flutter Web

```bash
flutter clean
flutter pub get
flutter build web --release \
  --dart-define=ENV=production \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/
```

Output: `build/web/`

> [!TIP]
> Use CanvasKit renderer for best Arabic text rendering fidelity (required for RTL support).

---

## 3. Deploy Security Rules

Always deploy rules **before** the app:

```bash
firebase deploy --only firestore:rules,storage
```

---

## 4. Deploy Firestore Indexes

```bash
node tool/gen_indexes.js
firebase deploy --only firestore:indexes
```

> [!NOTE]
> Index builds run asynchronously in Firestore. Large collections may take several minutes. Monitor progress in Firebase Console → Firestore → Indexes.

---

## 5. Deploy Cloud Functions

```bash
cd functions
npm ci
npm run build
cd ..
firebase deploy --only functions
```

> [!IMPORTANT]
> Verify function logs after deploy: `firebase functions:log`

---

## 6. Deploy Flutter Web Hosting

```bash
firebase deploy --only hosting
```

The site is live at:
- `https://YOUR_PROJECT.web.app`
- `https://YOUR_PROJECT.firebaseapp.com`
- Your custom domain (if configured)

---

## 7. Full Deploy (All at Once)

```bash
# After building the web app
firebase deploy
```

This deploys: hosting, functions, Firestore rules + indexes, Storage rules.

---

## 8. Custom Domain Setup

1. Firebase Console → Hosting → **Add custom domain**
2. Enter your domain (e.g. `souqtaiz.com`)
3. Add the two DNS records (A records or CNAME) to your registrar
4. Wait for SSL certificate provisioning (up to 24 hours)

---

## 9. Post-Deployment Verification

```bash
# Check live site loads
curl -I https://your-domain.com

# Check functions are healthy
firebase functions:log --only moderateListing

# Spot-check Firestore
firebase firestore:databases:list
```

Also manually verify in browser:
1. Homepage loads in Arabic (RTL layout)
2. Register a new user → email verification arrives
3. Create a listing → appears in Firestore Console
4. Admin login works → moderation queue visible

---

## 10. Rollback

```bash
# List recent hosting releases
firebase hosting:releases:list

# Roll back to a specific release
firebase hosting:clone SOURCE_SITE_ID:RELEASE_ID TARGET_SITE_ID
```

For Cloud Functions rollback, re-deploy the previous git tag:

```bash
git checkout v1.2.3
cd functions && npm ci && npm run build && cd ..
firebase deploy --only functions
```

---

## 11. Monitoring and Alerts

| Tool | Purpose |
|---|---|
| Firebase Console → Functions → Logs | Cloud Function execution errors |
| Firebase Console → Authentication | Suspicious login activity |
| Firebase Console → Firestore → Usage | Read/write quotas |
| Google Cloud Monitoring | Custom alerts on function errors |

Set up an alert for function error rate > 1%:

1. Google Cloud Console → Monitoring → Alerting → **Create policy**
2. Metric: `cloudfunctions.googleapis.com/function/execution_count` with label `status = error`
3. Notify via email or PagerDuty

---

## 12. Performance Considerations

| Area | Recommendation |
|---|---|
| Firestore reads | Use `limit()` on all list queries; never unbounded reads |
| Images | Compressed to ≤5 MB per image, ≤8 images per listing |
| Cloud Functions | Set `minInstances: 1` for `moderateListing` to reduce cold starts |
| Hosting | CDN cache headers are set automatically by Firebase Hosting |
| Flutter Web | CanvasKit renderer (~2.5 MB download); consider HTML renderer for first-paint speed |

---

## 13. Security Hardening

- **App Check**: Enforce in production — prevents unauthorized API calls
- **Firestore Rules**: Never use `allow read, write: if true` in production
- **Storage Rules**: Validate file type and size in rules (matches `lib/core/validators/validators.dart`)
- **Functions**: Admin operations use Firebase Admin SDK with service account; never expose admin credentials to client
- **Rate Limiting**: `tooManyRequests` failure type handled; consider Cloud Armor for DDoS

---

## 14. CI/CD Pipeline (GitHub Actions Example)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Firebase

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter test --no-pub
      - run: flutter analyze --no-pub
      - run: flutter build web --release --dart-define=ENV=production
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          projectId: YOUR_PROJECT_ID
```

> [!IMPORTANT]
> Store `FIREBASE_SERVICE_ACCOUNT` as a GitHub secret. Never commit service account JSON to the repository.
