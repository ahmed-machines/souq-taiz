/// Route paths, defined once to avoid string duplication.
abstract final class RouteNames {
  static const String splash = '/splash';
  static const String home = '/';
  static const String search = '/search';
  static const String listing = '/listing/:id';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String favorites = '/favorites';
  static const String account = '/account';
  static const String seller = '/seller';
  static const String sellerNew = '/seller/new';
  static const String sellerEdit = '/seller/edit/:id';
  static const String messages = '/messages';
  static const String chat = '/messages/:id';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String adminListings = '/admin/listings';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
  static const String adminCategories = '/admin/categories';
  static const String adminLocations = '/admin/locations';
  static const String adminLogs = '/admin/logs';

  static String listingPath(String id) => '/listing/$id';
  static String sellerEditPath(String id) => '/seller/edit/$id';
  static String chatPath(String id) => '/messages/$id';
  static String searchPath({String? category, String? query}) => Uri(
    path: search,
    queryParameters: {
      'category': ?category,
      if (query != null && query.isNotEmpty) 'q': query,
    },
  ).toString();
}
