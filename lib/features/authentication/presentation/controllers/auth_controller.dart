import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../domain/entities/app_user.dart';

/// Live auth state (null = signed out).
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Current user or null (also null while auth state is loading).
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authStateProvider).value,
);

/// Executes auth actions. Each method returns a [Failure] on error, null on
/// success, and exposes loading state through `state`.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> _run(Future<Result<Object?>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }

  Future<Failure?> signIn(String email, String password) => _run(
    () => ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password),
  );

  Future<Failure?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) => _run(
    () => ref
        .read(authRepositoryProvider)
        .signUp(
          email: email,
          password: password,
          displayName: name,
          phone: phone,
        ),
  );

  Future<Failure?> signInWithGoogle() =>
      _run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  Future<Failure?> sendPasswordReset(String email) =>
      _run(() => ref.read(authRepositoryProvider).sendPasswordReset(email));

  Future<Failure?> resendVerification() =>
      _run(() => ref.read(authRepositoryProvider).sendEmailVerification());

  Future<void> signOut() =>
      _run(() => ref.read(authRepositoryProvider).signOut());
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
