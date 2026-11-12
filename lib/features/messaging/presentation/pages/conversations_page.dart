import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/messaging_providers.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final me = ref.watch(currentUserProvider)?.uid ?? '';
    final convs = ref.watch(conversationsProvider);
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.messagesTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          convs.when(
            loading: () => const SkeletonBox(height: 80),
            error: (_, _) => ErrorState(
              message: l10n.errUnknown,
              onRetry: () => ref.invalidate(conversationsProvider),
            ),
            data: (items) => items.isEmpty
                ? EmptyState(
                    message: l10n.messagesEmpty,
                    icon: Icons.chat_bubble_outline,
                  )
                : Column(
                    children: [
                      for (final c in items)
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(c.otherName(me)),
                          subtitle: Text(
                            '${c.listingTitle}\n${c.lastMessage}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: c.lastMessageAt == null
                              ? null
                              : Text(
                                  DateFormat.MMMd(
                                    lang,
                                  ).format(c.lastMessageAt!),
                                ),
                          onTap: () => context.go(RouteNames.chatPath(c.id)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
