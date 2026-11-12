import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/responsive_context.dart';

/// Separate administrative shell with its own navigation (not the public
/// header). Access is guarded by `RouteGuards` and enforced server-side.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _routes = [
    RouteNames.admin,
    RouteNames.adminListings,
    RouteNames.adminUsers,
    RouteNames.adminReports,
    RouteNames.adminCategories,
    RouteNames.adminLocations,
    RouteNames.adminLogs,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final path = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(path).clamp(0, _routes.length - 1);
    final labels = [
      (Icons.dashboard_outlined, l10n.adminDashboard),
      (Icons.fact_check_outlined, l10n.adminModeration),
      (Icons.people_outline, l10n.adminUsers),
      (Icons.flag_outlined, l10n.adminReports),
      (Icons.category_outlined, l10n.adminCategories),
      (Icons.place_outlined, l10n.adminLocations),
      (Icons.history, l10n.adminLogs),
    ];

    final destinations = [
      for (final (icon, label) in labels)
        NavigationRailDestination(icon: Icon(icon), label: Text(label)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteNames.home),
            child: Text(l10n.navHome),
          ),
        ],
      ),
      drawer: context.isDesktop
          ? null
          : Drawer(
              child: ListView(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    ListTile(
                      leading: Icon(labels[i].$1),
                      title: Text(labels[i].$2),
                      selected: i == index,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(_routes[i]);
                      },
                    ),
                ],
              ),
            ),
      body: Row(
        children: [
          if (context.isDesktop)
            NavigationRail(
              extended: true,
              selectedIndex: index,
              destinations: destinations,
              onDestinationSelected: (i) => context.go(_routes[i]),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
