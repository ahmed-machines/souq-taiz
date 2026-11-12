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
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/firestore_messaging_repository.dart';
import '../controllers/messaging_providers.dart';

/// One conversation. The stream provider is auto-disposed with the page.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = ref.read(currentUserProvider);
    final value = _text.text.trim();
    if (user == null || value.isEmpty || !user.canPublish) return;
    _text.clear();
    try {
      await ref
          .read(messagingRepositoryProvider)
          .sendMessage(
            conversationId: widget.conversationId,
            senderId: user.uid,
            text: value,
          );
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          FailureMapper.from(e).message(AppLocalizations.of(context)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final me = ref.watch(currentUserProvider);
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final scheme = Theme.of(context).colorScheme;

    // Mark incoming messages as read whenever the list changes.
    ref.listen(messagesProvider(widget.conversationId), (_, next) {
      final user = ref.read(currentUserProvider);
      if (user != null &&
          (next.value?.any((m) => !m.isRead && m.senderId != user.uid) ??
              false)) {
        ref
            .read(messagingRepositoryProvider)
            .markRead(widget.conversationId, user.uid);
      }
    });

    return Column(
      children: [
        Expanded(
          child: messages.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorState(
              message: FailureMapper.from(e).message(l10n),
              onRetry: () =>
                  ref.invalidate(messagesProvider(widget.conversationId)),
            ),
            data: (items) => ListView.builder(
              reverse: true, // newest first from the query
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final m = items[i];
                final mine = m.senderId == me?.uid;
                return Align(
                  alignment: mine
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: mine
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(m.text),
                        Text(
                          '${DateFormat.Hm(lang).format(m.createdAt)}${mine ? ' · ${m.isRead ? l10n.messageRead : l10n.messageSent}' : ''}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    maxLength: FirestoreMessagingRepository.maxMessageLength,
                    decoration: InputDecoration(
                      hintText: l10n.typeMessage,
                      counterText: '',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton.filled(
                  tooltip: l10n.send,
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
