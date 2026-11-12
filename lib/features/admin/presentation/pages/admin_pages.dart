import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../authentication/domain/entities/app_user.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/controllers/category_providers.dart';
import '../../../locations/domain/entities/location.dart';
import '../../../locations/presentation/controllers/location_providers.dart';
import '../../domain/repositories/admin_repository.dart';
import '../controllers/admin_providers.dart';

/// Runs a privileged action, reports errors, then refreshes [refresh].
Future<void> _run(
  BuildContext context,
  Future<void> Function() action,
  VoidCallback refresh,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    await action();
    refresh();
    if (context.mounted) showToast(context, l10n.actionDone);
  } catch (e) {
    if (context.mounted) {
      showToast(context, FailureMapper.from(e).message(l10n));
    }
  }
}

Widget _async<T>(
  BuildContext context,
  AsyncValue<T> value,
  VoidCallback retry,
  Widget Function(T) builder,
) {
  final l10n = AppLocalizations.of(context);
  return value.when(
    loading: () => const SkeletonBox(height: 120),
    error: (e, _) => ErrorState(
      message: FailureMapper.from(e).message(l10n),
      onRetry: retry,
    ),
    data: builder,
  );
}

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _async(
      context,
      ref.watch(adminStatsProvider),
      () => ref.invalidate(adminStatsProvider),
      (s) {
        Widget card(String label, int v) => Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$v', style: Theme.of(context).textTheme.headlineMedium),
                Text(label),
              ],
            ),
          ),
        );
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            card(l10n.statUsers, s.users),
            card(l10n.statPending, s.pendingListings),
            card(l10n.statPublished, s.publishedListings),
            card(l10n.statOpenReports, s.openReports),
          ],
        );
      },
    );
  }
}

class AdminModerationPage extends ConsumerWidget {
  const AdminModerationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(adminRepositoryProvider);
    void refresh() => ref.invalidate(pendingListingsProvider);
    return _async(context, ref.watch(pendingListingsProvider), refresh, (
      items,
    ) {
      if (items.isEmpty) return EmptyState(message: l10n.noData);
      return Column(
        children: [
          for (final l in items)
            Card(
              child: ListTile(
                title: Text(l.title),
                subtitle: Text(
                  '${l.ownerName}\n${l.description}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: l10n.approve,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: () => _run(
                        context,
                        () => repo.moderateListing(
                          listingId: l.id,
                          approve: true,
                        ),
                        refresh,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.reject,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final reason = await _askText(
                          context,
                          l10n.rejectReasonHint,
                        );
                        if (reason != null && context.mounted) {
                          await _run(
                            context,
                            () => repo.moderateListing(
                              listingId: l.id,
                              approve: false,
                              reason: reason,
                            ),
                            refresh,
                          );
                        }
                      },
                    ),
                    IconButton(
                      tooltip: l10n.feature,
                      icon: const Icon(Icons.star_outline),
                      onPressed: () => _run(
                        context,
                        () => repo.setFeatured(listingId: l.id, featured: true),
                        refresh,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

Future<String?> _askText(BuildContext context, String label) async {
  final l10n = AppLocalizations.of(context);
  final c = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        maxLength: 300,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
  final text = c.text.trim();
  c.dispose();
  return ok == true ? text : null;
}

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(currentUserProvider);
    final repo = ref.read(adminRepositoryProvider);
    void refresh() => ref.invalidate(adminUsersProvider);
    return _async(
      context,
      ref.watch(adminUsersProvider),
      refresh,
      (users) => Column(
        children: [
          for (final u in users)
            Card(
              child: ListTile(
                title: Text(u.displayName),
                subtitle: Text(
                  '${u.email} · ${u.role.value}${u.status == AccountStatus.suspended ? ' · ${l10n.suspend}' : ''}',
                ),
                trailing:
                    u.uid == me?.uid ||
                        u.role.isAdmin && me?.role != UserRole.superAdmin
                    ? null
                    : Wrap(
                        children: [
                          TextButton(
                            onPressed: () => _run(
                              context,
                              () => repo.setUserSuspended(
                                uid: u.uid,
                                suspended: u.status == AccountStatus.active,
                              ),
                              refresh,
                            ),
                            child: Text(
                              u.status == AccountStatus.active
                                  ? l10n.suspend
                                  : l10n.unsuspend,
                            ),
                          ),
                          if (me?.role == UserRole.superAdmin)
                            PopupMenuButton<UserRoleValue>(
                              onSelected: (r) => _run(
                                context,
                                () => repo.setUserRole(uid: u.uid, role: r),
                                refresh,
                              ),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: UserRoleValue.buyer,
                                  child: Text(l10n.roleBuyer),
                                ),
                                PopupMenuItem(
                                  value: UserRoleValue.seller,
                                  child: Text(l10n.roleSeller),
                                ),
                                PopupMenuItem(
                                  value: UserRoleValue.admin,
                                  child: Text(l10n.roleAdmin),
                                ),
                              ],
                            ),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(adminRepositoryProvider);
    void refresh() => ref.invalidate(openReportsProvider);
    return _async(context, ref.watch(openReportsProvider), refresh, (items) {
      if (items.isEmpty) return EmptyState(message: l10n.noData);
      return Column(
        children: [
          for (final r in items)
            Card(
              child: ListTile(
                title: Text('${r.reason} · ${r.listingId}'),
                subtitle: Text(r.details),
                trailing: Wrap(
                  children: [
                    TextButton(
                      onPressed: () => _run(
                        context,
                        () => repo.resolveReport(
                          reportId: r.id,
                          removeListing: false,
                        ),
                        refresh,
                      ),
                      child: Text(l10n.dismissReport),
                    ),
                    TextButton(
                      onPressed: () => _run(
                        context,
                        () => repo.resolveReport(
                          reportId: r.id,
                          removeListing: true,
                        ),
                        refresh,
                      ),
                      child: Text(l10n.removeListing),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

class AdminLogsPage extends ConsumerWidget {
  const AdminLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    return _async(
      context,
      ref.watch(auditLogsProvider),
      () => ref.invalidate(auditLogsProvider),
      (logs) => Column(
        children: [
          for (final e in logs)
            ListTile(
              dense: true,
              title: Text('${e.action} → ${e.targetId}'),
              subtitle: Text(
                '${e.actorId} · ${DateFormat.yMMMd(lang).add_Hm().format(e.createdAt)}',
              ),
            ),
        ],
      ),
    );
  }
}

/// Manage categories (add/deactivate). Writes are validated by Firestore rules.
class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final repo = ref.read(categoryRepositoryProvider);
    void refresh() => ref.invalidate(categoriesProvider);
    return _async(
      context,
      ref.watch(categoriesProvider),
      refresh,
      (cats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.add),
            onPressed: () async {
              final r = await showNamePairDialog(context);
              if (r == null || !context.mounted) return;
              final id = r.$2.toLowerCase().replaceAll(
                RegExp(r'[^a-z0-9]+'),
                '_',
              );
              await _run(
                context,
                () => repo.upsert(
                  Category(
                    id: id,
                    name: LocalizedName(ar: r.$1, en: r.$2),
                    order: cats.length,
                  ),
                ),
                refresh,
              );
            },
          ),
          for (final c in cats)
            ListTile(
              title: Text(c.name.of(lang)),
              subtitle: Text(c.isSubcategory ? '↳ ${c.parentId}' : c.id),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _run(context, () => repo.deactivate(c.id), refresh),
              ),
            ),
        ],
      ),
    );
  }
}

class AdminLocationsPage extends ConsumerWidget {
  const AdminLocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final repo = ref.read(locationRepositoryProvider);
    void refresh() => ref.invalidate(locationsProvider);
    return _async(
      context,
      ref.watch(locationsProvider),
      refresh,
      (locs) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.add),
            onPressed: () async {
              final r = await showNamePairDialog(context);
              if (r == null || !context.mounted) return;
              final id = r.$2.toLowerCase().replaceAll(
                RegExp(r'[^a-z0-9]+'),
                '_',
              );
              await _run(
                context,
                () => repo.upsert(
                  Location(
                    id: id,
                    name: LocalizedName(ar: r.$1, en: r.$2),
                  ),
                ),
                refresh,
              );
            },
          ),
          for (final l in locs)
            ListTile(
              title: Text(l.name.of(lang)),
              subtitle: Text(l.parentId ?? l.id),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _run(context, () => repo.deactivate(l.id), refresh),
              ),
            ),
        ],
      ),
    );
  }
}

/// Asks for an (Arabic, English) name pair; the English name seeds the id.
Future<(String, String)?> showNamePairDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final ar = TextEditingController();
  final en = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: ar,
            decoration: InputDecoration(labelText: l10n.nameAr),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: en,
            decoration: InputDecoration(labelText: l10n.nameEn),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  final result = (ar.text.trim(), en.text.trim());
  ar.dispose();
  en.dispose();
  return ok == true && result.$1.isNotEmpty && result.$2.isNotEmpty
      ? result
      : null;
}
