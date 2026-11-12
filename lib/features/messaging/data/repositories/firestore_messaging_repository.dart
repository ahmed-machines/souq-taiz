import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messaging_repository.dart';

/// Conversations at `conversations/{listingId_buyerId}`, messages in the
/// `messages` subcollection. Rules restrict access to the two participants.
class FirestoreMessagingRepository implements MessagingRepository {
  FirestoreMessagingRepository(this._db);

  static const int maxMessageLength = 1000;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _convs =>
      _db.collection('conversations');

  @override
  Future<String> openConversation({
    required String listingId,
    required String listingTitle,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  }) async {
    final id = '${listingId}_$buyerId';
    final ref = _convs.doc(id);
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({
        'listingId': listingId,
        'listingTitle': listingTitle,
        'participantIds': [buyerId, sellerId],
        'participantNames': {buyerId: buyerName, sellerId: sellerName},
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return id;
  }

  @override
  Stream<List<Conversation>> watchConversations(String uid, {int limit = 30}) =>
      _convs
          .where('participantIds', arrayContains: uid)
          .orderBy('lastMessageAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map(_conversation).toList());

  @override
  Stream<List<Message>> watchMessages(
    String conversationId, {
    int limit = 50,
  }) => _convs
      .doc(conversationId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(_message).toList());

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > maxMessageLength) {
      throw ArgumentError('Invalid message length');
    }
    final convRef = _convs.doc(conversationId);
    final batch = _db.batch();
    batch.set(convRef.collection('messages').doc(), {
      'senderId': senderId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });
    batch.update(convRef, {
      'lastMessage': trimmed.length > 80 ? trimmed.substring(0, 80) : trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
    await batch.commit();
  }

  @override
  Future<void> markRead(String conversationId, String readerId) async {
    final unread = await _convs
        .doc(conversationId)
        .collection('messages')
        .where('readAt', isNull: true)
        .limit(50)
        .get();
    final batch = _db.batch();
    var count = 0;
    for (final d in unread.docs) {
      if (d.data()['senderId'] != readerId) {
        batch.update(d.reference, {'readAt': FieldValue.serverTimestamp()});
        count++;
      }
    }
    if (count > 0) await batch.commit();
  }

  Conversation _conversation(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Conversation(
      id: d.id,
      listingId: (m['listingId'] ?? '') as String,
      listingTitle: (m['listingTitle'] ?? '') as String,
      participantIds: List<String>.from(
        (m['participantIds'] ?? const <String>[]) as List,
      ),
      participantNames: Map<String, String>.from(
        (m['participantNames'] ?? const <String, String>{}) as Map,
      ),
      lastMessage: (m['lastMessage'] ?? '') as String,
      lastMessageAt: (m['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: m['lastSenderId'] as String?,
    );
  }

  Message _message(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Message(
      id: d.id,
      senderId: (m['senderId'] ?? '') as String,
      text: (m['text'] ?? '') as String,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (m['readAt'] as Timestamp?)?.toDate(),
    );
  }
}
