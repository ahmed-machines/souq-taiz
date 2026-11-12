import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/admin_entities.dart';

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => ref.watch(adminRepositoryProvider).getStats(),
);

final pendingListingsProvider = FutureProvider.autoDispose<List<Listing>>(
  (ref) => ref.watch(adminRepositoryProvider).getPendingListings(),
);

final adminUsersProvider = FutureProvider.autoDispose<List<AdminUserSummary>>(
  (ref) => ref.watch(adminRepositoryProvider).getUsers(),
);

final openReportsProvider = FutureProvider.autoDispose<List<Report>>(
  (ref) => ref.watch(adminRepositoryProvider).getOpenReports(),
);

final auditLogsProvider = FutureProvider.autoDispose<List<AuditLogEntry>>(
  (ref) => ref.watch(adminRepositoryProvider).getAuditLogs(),
);
