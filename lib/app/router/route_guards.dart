import '../../features/authentication/domain/entities/app_user.dart';
import 'route_names.dart';

/// Pure redirect logic for GoRouter (unit-testable). This is a UX layer
/// only: real authorization is enforced by Firestore rules / Cloud Functions.
abstract final class RouteGuards {
  static const _protectedPrefixes = [
    RouteNames.favorites,
    RouteNames.account,
    RouteNames.seller,
    RouteNames.messages,
    RouteNames.notifications,
    RouteNames.admin,
  ];
  static const _guestOnly = [
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
  ];

  static bool isProtected(String path) =>
      _protectedPrefixes.any((p) => path == p || path.startsWith('$p/'));

  /// Returns the redirect target, or null to stay.
  static String? redirect({
    required Uri location,
    required bool isLoading,
    required AppUser? user,
  }) {
    final path = location.path;
    if (isLoading) {
      return isProtected(path)
          ? Uri(
              path: RouteNames.splash,
              queryParameters: {'from': location.toString()},
            ).toString()
          : null;
    }
    if (path == RouteNames.splash) {
      return location.queryParameters['from'] ?? RouteNames.home;
    }
    if (user == null && isProtected(path)) {
      return Uri(
        path: RouteNames.login,
        queryParameters: {'from': location.toString()},
      ).toString();
    }
    if (user != null && _guestOnly.contains(path)) {
      return location.queryParameters['from'] ?? RouteNames.home;
    }
    if ((path == RouteNames.admin || path.startsWith('${RouteNames.admin}/')) &&
        !(user?.isAdmin ?? false)) {
      return RouteNames.home;
    }
    return null;
  }
}
