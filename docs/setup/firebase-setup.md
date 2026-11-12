# Firebase Setup Guide

> [!IMPORTANT]
> Complete these steps before running Souq Taiz in Firebase-connected mode. Without this, the app runs in Demo Mode with mock data only.

## Prerequisites

- Node.js ≥ 18 and npm
- Flutter SDK (stable channel)
- A Google account with access to [Firebase Console](https://console.firebase.google.com)

---

## 1. Create a Firebase Project

1. Open [Firebase Console](https://console.firebase.google.com) → **Add project**
2. Name it **souq-taiz** (or any name you prefer)
3. Enable Google Analytics → select or create an Analytics account
4. Click **Create project**

---

## 2. Enable Firebase Services

### Authentication
1. Go to **Build → Authentication → Get started**
2. Enable **Email/Password** provider
3. Enable **Google** provider — configure the OAuth client for your domain

### Firestore
1. Go to **Build → Firestore Database → Create database**
2. Start in **production mode** (rules are deployed separately)
3. Choose region: `me-central1` (Dammam) or `europe-west1` for lowest latency from Yemen

### Storage
1. Go to **Build → Storage → Get started**
2. Use production mode
3. Same region as Firestore

### Cloud Functions
1. Go to **Build → Functions → Get started**
2. Upgrade to **Blaze (pay-as-you-go)** plan — required for Cloud Functions

### App Check
1. Go to **Build → App Check → Get started**
2. Register your web app with **reCAPTCHA v3**

---

## 3. Register the Web App

1. In Firebase project overview → **Add app → Web**
2. App nickname: `souq-taiz-web`
3. Enable Firebase Hosting
4. Copy the `firebaseConfig` object — you will need it next

---

## 4. Add Firebase Config to the Flutter Project

Create the file `web/firebase-config.js`:

```js
// web/firebase-config.js  –  populated from Firebase Console
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

> [!WARNING]
> Never commit `web/firebase-config.js` with real credentials to a public repository. Add it to `.gitignore`:
> ```
> web/firebase-config.js
> ```
> Use `.firebaserc.example` and CI secrets for team deployments.

---

## 5. Firebase CLI Setup

```bash
npm install -g firebase-tools
firebase login
firebase use --add          # select your project → alias: default
```

---

## 6. Deploy Security Rules and Indexes

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore composite indexes (may take a few minutes)
node tool/gen_indexes.js
firebase deploy --only firestore:indexes

# Deploy Storage rules
firebase deploy --only storage
```

---

## 7. Deploy Cloud Functions

```bash
cd functions
npm install
npm run build        # TypeScript compile
cd ..
firebase deploy --only functions
```

> [!NOTE]
> First deploy of Cloud Functions may take 3–5 minutes. Watch progress in the Firebase Console → Functions tab.

---

## 8. Seed Initial Data (Optional)

Run the seed script to populate categories and locations:

```bash
node tool/seed_firestore.js --project YOUR_PROJECT_ID
```

This creates:
- 10 top-level categories with subcategories
- Taiz governorate locations
- An initial admin user placeholder

---

## 9. Deploy the Flutter Web App

```bash
flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/
firebase deploy --only hosting
```

---

## 10. Verify

1. Open your hosting URL (e.g. `https://souq-taiz.web.app`)
2. Register a new user — confirm email verification email arrives
3. Try creating a listing — verify it appears in Firestore Console
4. Test image upload — verify file appears in Storage Console

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `FirebaseException: permission-denied` | Re-deploy Firestore rules; check auth state |
| Functions cold start > 10 s | Normal on first invocation; set minimum instances in production |
| Images not loading | Verify Storage CORS settings and Storage rules allow reads |
| Arabic text shows garbled characters | Ensure all files saved as UTF-8 (use `python tool/gen_arb.py`) |
