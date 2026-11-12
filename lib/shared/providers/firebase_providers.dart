import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bootstrap/firebase_bootstrap.dart';

/// Result of Firebase initialization; overridden in `bootstrap()`.
final firebaseStatusProvider = Provider<FirebaseStatus>(
  (ref) => FirebaseStatus.notConfigured,
);

/// True when Firebase is initialized and real backends can be used.
final firebaseReadyProvider = Provider<bool>(
  (ref) => ref.watch(firebaseStatusProvider) == FirebaseStatus.initialized,
);

T _requireFirebase<T>(Ref ref, T Function() create) {
  if (!ref.watch(firebaseReadyProvider)) {
    throw StateError(
      'Firebase is not configured. See docs/setup/firebase-setup.md',
    );
  }
  return create();
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => _requireFirebase(ref, () => FirebaseFirestore.instance),
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => _requireFirebase(ref, () => FirebaseAuth.instance),
);
final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => _requireFirebase(ref, () => FirebaseStorage.instance),
);
final firebaseFunctionsProvider = Provider<FirebaseFunctions>(
  (ref) => _requireFirebase(ref, () => FirebaseFunctions.instance),
);
