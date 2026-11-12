import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// In-app notifications at `users/{uid}/notifications`. Documents are created
/// only by Cloud Functions; clients may read and mark them as read.
class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  @override
  Stream<List<AppNotification>> watch(String uid, {int limit = 30}) => _col(uid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (s) => s.docs.map((d) {
          final m = d.data();
          return AppNotification(
            id: d.id,
            type: (m['type'] ?? '') as String,
            listingId: m['listingId'] as String?,
            listingTitle: m['listingTitle'] as String?,
            reason: m['reason'] as String?,
            createdAt:
                (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: (m['read'] ?? false) as bool,
          );
        }).toList(),
      );

  @override
  Future<void> markRead(String uid, String notificationId) =>
      _col(uid).doc(notificationId).update({'read': true});

  @override
  Future<void> markAllRead(String uid) async {
    final unread = await _col(
      uid,
    ).where('read', isEqualTo: false).limit(50).get();
    final batch = _db.batch();
    for (final d in unread.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }
}
