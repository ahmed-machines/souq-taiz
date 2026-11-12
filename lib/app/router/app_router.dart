import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_pages.dart';
import '../../features/admin/presentation/widgets/admin_shell.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/presentation/pages/account_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/listings/presentation/pages/listing_details_page.dart';
import '../../features/listings/presentation/pages/listing_form_page.dart';
import '../../features/messaging/presentation/pages/chat_page.dart';
import '../../features/messaging/presentation/pages/conversations_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/search/domain/search_query.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/seller_dashboard/presentation/pages/seller_dashboard_page.dart';
import '../../shared/widgets/app_shell.dart';
import '../localization/generated/app_localizations.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// Router provided through DI; re-evaluates guards when auth state changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: RouteNames.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return RouteGuards.redirect(
        location: state.uri,
        isLoading: auth.isLoading,
        user: auth.value,
      );
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (_, _) => const HomePage()),
          GoRoute(
            path: RouteNames.search,
            builder: (_, state) => SearchPage(
              key: ValueKey(state.uri.toString()),
              initialQuery: SearchQuery(
                keyword: state.uri.queryParameters['q'] ?? '',
                categoryId: state.uri.queryParameters['category'],
                featuredOnly: state.uri.queryParameters['featured'] == '1',
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.listing,
            builder: (_, state) =>
                ListingDetailsPage(listingId: state.pathParameters['id']!),
          ),
          GoRoute(path: RouteNames.login, builder: (_, _) => const LoginPage()),
          GoRoute(
            path: RouteNames.register,
            builder: (_, _) => const RegisterPage(),
          ),
          GoRoute(
            path: RouteNames.forgotPassword,
            builder: (_, _) => const ForgotPasswordPage(),
          ),
          GoRoute(
            path: RouteNames.favorites,
            builder: (_, _) => const FavoritesPage(),
          ),
          GoRoute(
            path: RouteNames.account,
            builder: (_, _) => const AccountPage(),
          ),
          GoRoute(
            path: RouteNames.seller,
            builder: (_, _) => const SellerDashboardPage(),
          ),
          GoRoute(
            path: RouteNames.sellerNew,
            builder: (_, _) => const ListingFormPage(),
          ),
          GoRoute(
            path: RouteNames.sellerEdit,
            builder: (_, state) =>
                ListingFormPage(editId: state.pathParameters['id']),
          ),
          GoRoute(
            path: RouteNames.messages,
            builder: (_, _) => const ConversationsPage(),
          ),
          GoRoute(
            path: RouteNames.chat,
            builder: (_, state) =>
                ChatPage(conversationId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, _) => const NotificationsPage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, _, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.admin,
            builder: (_, _) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: RouteNames.adminListings,
            builder: (_, _) => const AdminModerationPage(),
          ),
          GoRoute(
            path: RouteNames.adminUsers,
            builder: (_, _) => const AdminUsersPage(),
          ),
          GoRoute(
            path: RouteNames.adminReports,
            builder: (_, _) => const AdminReportsPage(),
          ),
          GoRoute(
            path: RouteNames.adminCategories,
            builder: (_, _) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: RouteNames.adminLocations,
            builder: (_, _) => const AdminLocationsPage(),
          ),
          GoRoute(
            path: RouteNames.adminLogs,
            builder: (_, _) => const AdminLogsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
  ref.onDispose(router.dispose);
  return router;
});

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.pageNotFound),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(RouteNames.home),
              child: Text(l10n.backToHome),
            ),
          ],
        ),
      ),
    );
  }
}
