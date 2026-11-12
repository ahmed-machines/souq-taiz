import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Used when Firebase is not configured: nobody is signed in and every
/// action fails with a configuration error (no fake sessions).
class UnconfiguredAuthRepository implements AuthRepository {
  static const _err = Failure(FailureType.configuration);

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(null);

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async => const Err(_err);

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async => const Err(_err);

  @override
  Future<Result<AppUser>> signInWithGoogle() async => const Err(_err);

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<void>> sendPasswordReset(String email) async => const Err(_err);

  @override
  Future<Result<void>> sendEmailVerification() async => const Err(_err);

  @override
  Future<Result<void>> reload() async => const Err(_err);
}
