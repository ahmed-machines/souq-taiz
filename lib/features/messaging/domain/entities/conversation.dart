import 'package:flutter/foundation.dart';

@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage = '',
    this.lastMessageAt,
    this.lastSenderId,
  });

  final String id;
  final String listingId;
  final String listingTitle;

  /// Exactly two participants: buyer and seller.
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;

  String otherParticipantId(String myUid) =>
      participantIds.firstWhere((p) => p != myUid, orElse: () => myUid);

  String otherName(String myUid) =>
      participantNames[otherParticipantId(myUid)] ?? '';
}

@immutable
class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;
}
