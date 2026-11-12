import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase Auth + Firestore `users`/`user_profiles` implementation.
///
/// New accounts are always created with role `buyer`; security rules reject
/// any other initial role. Elevated roles are granted only server-side.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().asyncMap((u) async {
        if (u == null) return null;
        try {
          return await _loadUser(u);
        } catch (_) {
          // Profile read failed (e.g. offline); degrade to a basic buyer.
          return _basicUser(u);
        }
      });

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(displayName.trim());
      await _createProfile(user, displayName.trim(), phone);
      await user.sendEmailVerification();
      return Success(await _loadUser(user));
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _checkActive(await _loadUser(cred.user!));
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      final cred = await _auth.signInWithPopup(GoogleAuthProvider());
      final user = cred.user!;
      final exists = (await _db.collection('users').doc(user.uid).get()).exists;
      if (!exists) await _createProfile(user, user.displayName ?? '', null);
      return _checkActive(await _loadUser(user));
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Success(null);
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return const Success(null);
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  @override
  Future<Result<void>> reload() async {
    try {
      await _auth.currentUser?.reload();
      return const Success(null);
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }

  Future<Result<AppUser>> _checkActive(AppUser user) async {
    if (user.isActive) return Success(user);
    await _auth.signOut();
    return const Err(Failure(FailureType.accountSuspended));
  }

  Future<void> _createProfile(User user, String name, String? phone) async {
    final batch = _db.batch();
    batch.set(_db.collection('users').doc(user.uid), {
      'email': user.email,
      'displayName': name,
      'phone': phone,
      'role': UserRole.buyer.value,
      'status': AccountStatus.active.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('user_profiles').doc(user.uid), {
      'displayName': name,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<AppUser> _loadUser(User u) async {
    final doc = await _db.collection('users').doc(u.uid).get();
    final m = doc.data();
    if (m == null) return _basicUser(u);
    return AppUser(
      uid: u.uid,
      email: u.email ?? (m['email'] as String? ?? ''),
      displayName: (m['displayName'] ?? u.displayName ?? '') as String,
      role: UserRole.parse(m['role'] as String?),
      status: AccountStatus.parse(m['status'] as String?),
      emailVerified: u.emailVerified,
      phone: m['phone'] as String?,
    );
  }

  AppUser _basicUser(User u) => AppUser(
    uid: u.uid,
    email: u.email ?? '',
    displayName: u.displayName ?? '',
    role: UserRole.buyer,
    status: AccountStatus.active,
    emailVerified: u.emailVerified,
  );
}
