import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_providers.dart';
import '../../app/localization/generated/app_localizations.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/extensions/responsive_context.dart';
import '../../features/authentication/domain/entities/app_user.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/locations/presentation/controllers/location_providers.dart';
import '../../features/notifications/presentation/controllers/notification_providers.dart';

enum _Menu { account, dashboard, favorites, messages, admin, logout }

/// Responsive site header with logo, search, location, auth actions.
class AppHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _submit(String q) => context.go(RouteNames.searchPath(query: q.trim()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final isMobile = context.isMobile;

    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 28,
            vertical: 10,
          ),
          child: Row(
            children: [
              // ── Logo ──────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go(RouteNames.home),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.primaryGradient.createShader(b),
                        child: Text(
                          'سوق تعز',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // ── Search ────────────────────────────────────────
              if (!isMobile)
                Expanded(
                  child: _SearchBar(
                    controller: _search,
                    onSubmitted: _submit,
                    hint: l10n.searchHint,
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 10),

              // ── Location ──────────────────────────────────────
              const _LocationChip(),

              // ── Language ──────────────────────────────────────
              _LanguageToggle(),

              // ── Sell button ───────────────────────────────────
              if (!isMobile) ...[
                const SizedBox(width: 6),
                _SellButton(label: l10n.navSell),
              ],

              // ── Notifications + Messages ───────────────────────
              if (user != null && !isMobile) ...[
                const SizedBox(width: 2),
                _NotificationsButton(),
                _MessagesButton(),
              ],

              const SizedBox(width: 4),

              // ── Auth ──────────────────────────────────────────
              if (user == null)
                _LoginButton(label: l10n.login)
              else
                _AccountAvatar(user: user),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.hint,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onSubmitted(controller.text),
            child: Container(
              margin: const EdgeInsets.all(5),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Location chip ────────────────────────────────────────────────────────────

class _LocationChip extends ConsumerWidget {
  const _LocationChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locations = ref.watch(locationsProvider).value ?? const [];
    final selected = ref.watch(selectedLocationProvider);
    final lang = Localizations.localeOf(context).languageCode;
    if (locations.isEmpty) return const SizedBox.shrink();

    final label = selected == null
        ? l10n.allLocations
        : (locations
                  .where((l) => l.id == selected)
                  .firstOrNull
                  ?.name
                  .of(lang) ??
              l10n.allLocations);

    return PopupMenuButton<String?>(
      tooltip: l10n.location,
      initialValue: selected,
      offset: const Offset(0, 44),
      onSelected: (v) => ref.read(selectedLocationProvider.notifier).select(v),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => [
        PopupMenuItem<String?>(value: null, child: Text(l10n.allLocations)),
        for (final loc in locations)
          PopupMenuItem<String?>(value: loc.id, child: Text(loc.name.of(lang))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.place_rounded, size: 15, color: AppColors.primary),
            const SizedBox(width: 3),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isAr ? 'EN' : 'ع',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Sell button ──────────────────────────────────────────────────────────────

class _SellButton extends StatelessWidget {
  const _SellButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(RouteNames.sellerNew),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: AppColors.amberGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 17,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notifications ────────────────────────────────────────────────────────────

class _NotificationsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider);
    return IconButton(
      tooltip: AppLocalizations.of(context).navNotifications,
      onPressed: () => context.go(RouteNames.notifications),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.secondary,
        textColor: Colors.white,
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Messages ─────────────────────────────────────────────────────────────────

class _MessagesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).navMessages,
    onPressed: () => context.go(RouteNames.messages),
    icon: const Icon(
      Icons.chat_bubble_outline_rounded,
      color: AppColors.textPrimary,
    ),
  );
}

// ── Login button ─────────────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size(80, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => context.go(RouteNames.login),
      child: Text(label),
    );
  }
}

// ── Account avatar ───────────────────────────────────────────────────────────

class _AccountAvatar extends ConsumerWidget {
  const _AccountAvatar({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final initial = user.displayName.isNotEmpty
        ? user.displayName[0]
        : '؟';

    return PopupMenuButton<_Menu>(
      tooltip: l10n.navAccount,
      offset: const Offset(0, 48),
      onSelected: (m) {
        switch (m) {
          case _Menu.account:
            context.go(RouteNames.account);
          case _Menu.dashboard:
            context.go(RouteNames.seller);
          case _Menu.favorites:
            context.go(RouteNames.favorites);
          case _Menu.messages:
            context.go(RouteNames.messages);
          case _Menu.admin:
            context.go(RouteNames.admin);
          case _Menu.logout:
            ref.read(authControllerProvider.notifier).signOut();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<_Menu>(
          enabled: false,
          value: _Menu.account,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName.isNotEmpty
                            ? user.displayName
                            : l10n.navAccount,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.email.isNotEmpty)
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        _menuItem(
          _Menu.dashboard,
          Icons.dashboard_outlined,
          l10n.navDashboard,
          context,
        ),
        _menuItem(
          _Menu.favorites,
          Icons.favorite_outline_rounded,
          l10n.navFavorites,
          context,
        ),
        _menuItem(
          _Menu.messages,
          Icons.chat_bubble_outline_rounded,
          l10n.navMessages,
          context,
        ),
        if (user.isAdmin)
          _menuItem(
            _Menu.admin,
            Icons.admin_panel_settings_outlined,
            l10n.navAdmin,
            context,
          ),
        const PopupMenuDivider(),
        PopupMenuItem<_Menu>(
          value: _Menu.logout,
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.logout,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  static PopupMenuItem<_Menu> _menuItem(
    _Menu value,
    IconData icon,
    String label,
    BuildContext ctx,
  ) => PopupMenuItem<_Menu>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label),
      ],
    ),
  );
}
