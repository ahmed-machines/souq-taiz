import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/app_notification.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const <AppNotification>[]);
  return ref.watch(notificationRepositoryProvider).watch(user.uid);
});

final unreadNotificationCountProvider = Provider<int>(
  (ref) => (ref.watch(notificationsProvider).value ?? const <AppNotification>[])
      .where((n) => !n.isRead)
      .length,
);
