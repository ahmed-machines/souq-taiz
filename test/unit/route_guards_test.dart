import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/app/router/route_guards.dart';
import 'package:souq_taiz/features/authentication/domain/entities/app_user.dart';

AppUser _user(UserRole role, {AccountStatus status = AccountStatus.active}) =>
    AppUser(
      uid: 'u',
      email: 'e@e.co',
      displayName: 'User',
      role: role,
      status: status,
      emailVerified: true,
    );

String? _r(String loc, {bool loading = false, AppUser? user}) =>
    RouteGuards.redirect(
      location: Uri.parse(loc),
      isLoading: loading,
      user: user,
    );

void main() {
  test('public routes are open to guests', () {
    for (final p in ['/', '/search', '/listing/abc', '/login']) {
      expect(_r(p), isNull, reason: p);
    }
  });

  test('guests are sent to login with a return path', () {
    final r = _r('/seller/new')!;
    expect(Uri.parse(r).path, '/login');
    expect(Uri.parse(r).queryParameters['from'], '/seller/new');
  });

  test('signed-in users skip login/register and return to origin', () {
    expect(_r('/login', user: _user(UserRole.buyer)), '/');
    expect(
      _r('/login?from=%2Ffavorites', user: _user(UserRole.buyer)),
      '/favorites',
    );
  });

  test('admin routes require an active admin', () {
    expect(_r('/admin', user: _user(UserRole.buyer)), '/');
    expect(_r('/admin/users', user: _user(UserRole.seller)), '/');
    expect(
      _r(
        '/admin',
        user: _user(UserRole.admin, status: AccountStatus.suspended),
      ),
      '/',
    );
    expect(_r('/admin', user: _user(UserRole.admin)), isNull);
    expect(_r('/admin/logs', user: _user(UserRole.superAdmin)), isNull);
  });

  test('protected routes wait on splash while auth loads', () {
    final r = _r('/favorites', loading: true)!;
    expect(Uri.parse(r).path, '/splash');
    expect(_r('/', loading: true), isNull);
    expect(
      _r('/splash?from=%2Ffavorites', user: _user(UserRole.buyer)),
      '/favorites',
    );
  });
}
