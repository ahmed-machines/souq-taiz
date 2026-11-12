import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notification_providers.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  String _text(AppLocalizations l, AppNotification n) => switch (n.type) {
    'listing_approved' => l.ntfApproved,
    'listing_rejected' => l.ntfRejected,
    'new_message' => l.ntfNewMessage,
    'account_status' => l.ntfAccount,
    _ => l.ntfStatus,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final user = ref.watch(currentUserProvider);
    final items = ref.watch(notificationsProvider);
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.notificationsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: user == null
                    ? null
                    : () => ref
                          .read(notificationRepositoryProvider)
                          .markAllRead(user.uid),
                child: Text(l10n.markAllRead),
              ),
            ],
          ),
          items.when(
            loading: () => const SkeletonBox(height: 60),
            error: (_, _) => ErrorState(
              message: l10n.errUnknown,
              onRetry: () => ref.invalidate(notificationsProvider),
            ),
            data: (list) => list.isEmpty
                ? EmptyState(
                    message: l10n.notificationsEmpty,
                    icon: Icons.notifications_none,
                  )
                : Column(
                    children: [
                      for (final n in list)
                        ListTile(
                          leading: Icon(
                            n.isRead
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                          ),
                          title: Text(
                            _text(l10n, n),
                            style: TextStyle(
                              fontWeight: n.isRead ? null : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if (n.listingTitle != null) n.listingTitle!,
                              if (n.reason != null) n.reason!,
                              DateFormat.yMMMd(lang).format(n.createdAt),
                            ].join(' · '),
                          ),
                          onTap: () {
                            if (user != null && !n.isRead) {
                              ref
                                  .read(notificationRepositoryProvider)
                                  .markRead(user.uid, n.id);
                            }
                            if (n.listingId != null) {
                              context.go(RouteNames.listingPath(n.listingId!));
                            }
                          },
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
