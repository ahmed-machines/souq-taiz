import '../entities/conversation.dart';

abstract interface class MessagingRepository {
  /// Finds or creates the conversation between buyer and the listing owner.
  Future<String> openConversation({
    required String listingId,
    required String listingTitle,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  });

  Stream<List<Conversation>> watchConversations(String uid, {int limit = 30});
  Stream<List<Message>> watchMessages(String conversationId, {int limit = 50});
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });

  /// Marks incoming messages as read by [readerId].
  Future<void> markRead(String conversationId, String readerId);
}
