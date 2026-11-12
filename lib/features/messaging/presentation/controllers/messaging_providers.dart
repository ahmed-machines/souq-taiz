import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/conversation.dart';

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const <Conversation>[]);
  return ref.watch(messagingRepositoryProvider).watchConversations(user.uid);
});

final messagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, conversationId) =>
      ref.watch(messagingRepositoryProvider).watchMessages(conversationId),
);
