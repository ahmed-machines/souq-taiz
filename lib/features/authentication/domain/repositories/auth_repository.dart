import '../../../../core/result/result.dart';
import '../entities/app_user.dart';

abstract interface class AuthRepository {
  /// Emits the signed-in user (with profile/role) or null.
  Stream<AppUser?> authStateChanges();

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  });
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });
  Future<Result<AppUser>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordReset(String email);
  Future<Result<void>> sendEmailVerification();

  /// Reloads the current user so `emailVerified` is fresh.
  Future<Result<void>> reload();
}
