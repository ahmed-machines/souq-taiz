import '../../../listings/domain/entities/listing.dart';
import '../entities/admin_entities.dart';

/// Privileged operations. Mutations go through Cloud Functions that verify
/// the caller's role server-side and write the audit log.
abstract interface class AdminRepository {
  Future<AdminStats> getStats();
  Future<List<Listing>> getPendingListings({int limit = 30});
  Future<void> moderateListing({
    required String listingId,
    required bool approve,
    String? reason,
  });
  Future<void> setFeatured({required String listingId, required bool featured});
  Future<List<AdminUserSummary>> getUsers({int limit = 50});
  Future<void> setUserSuspended({required String uid, required bool suspended});

  /// Super Admin only (enforced server-side).
  Future<void> setUserRole({required String uid, required UserRoleValue role});
  Future<List<Report>> getOpenReports({int limit = 30});
  Future<void> resolveReport({
    required String reportId,
    required bool removeListing,
  });
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 50});
}

/// Roles assignable through the admin API.
enum UserRoleValue { buyer, seller, admin }

/// Submitted by regular users from the listing page.
abstract interface class ReportRepository {
  Future<void> submit({
    required String listingId,
    required String reporterId,
    required String reason,
    required String details,
  });
}
