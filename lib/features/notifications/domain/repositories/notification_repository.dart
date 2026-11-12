import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watch(String uid, {int limit = 30});
  Future<void> markRead(String uid, String notificationId);
  Future<void> markAllRead(String uid);
}
