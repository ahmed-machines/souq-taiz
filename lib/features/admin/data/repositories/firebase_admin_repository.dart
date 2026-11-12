import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../authentication/domain/entities/app_user.dart';
import '../../../listings/data/models/listing_mapper.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

/// Reads use Firestore (rules restrict to admins); writes call callable
/// Cloud Functions defined in `functions/src/index.ts`.
class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Future<void> _call(String name, Map<String, dynamic> data) =>
      _functions.httpsCallable(name).call<void>(data);

  Future<int> _count(Query<Map<String, dynamic>> q) async =>
      (await q.count().get()).count ?? 0;

  @override
  Future<AdminStats> getStats() async => AdminStats(
    users: await _count(_db.collection('users')),
    pendingListings: await _count(
      _db
          .collection('listings')
          .where('status', isEqualTo: ListingStatus.pendingReview.value),
    ),
    publishedListings: await _count(
      _db
          .collection('listings')
          .where('status', isEqualTo: ListingStatus.published.value),
    ),
    openReports: await _count(
      _db.collection('reports').where('status', isEqualTo: 'open'),
    ),
  );

  @override
  Future<List<Listing>> getPendingListings({int limit = 30}) async {
    final snap = await _db
        .collection('listings')
        .where('status', isEqualTo: ListingStatus.pendingReview.value)
        .orderBy('createdAt')
        .limit(limit)
        .get();
    return snap.docs.map(ListingMapper.fromDoc).toList();
  }

  @override
  Future<void> moderateListing({
    required String listingId,
    required bool approve,
    String? reason,
  }) => _call('moderateListing', {
    'listingId': listingId,
    'approve': approve,
    'reason': reason,
  });

  @override
  Future<void> setFeatured({
    required String listingId,
    required bool featured,
  }) => _call('setFeatured', {'listingId': listingId, 'featured': featured});

  @override
  Future<List<AdminUserSummary>> getUsers({int limit = 50}) async {
    final snap = await _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return AdminUserSummary(
        uid: d.id,
        email: (m['email'] ?? '') as String,
        displayName: (m['displayName'] ?? '') as String,
        role: UserRole.parse(m['role'] as String?),
        status: AccountStatus.parse(m['status'] as String?),
      );
    }).toList();
  }

  @override
  Future<void> setUserSuspended({
    required String uid,
    required bool suspended,
  }) => _call('setUserSuspended', {'uid': uid, 'suspended': suspended});

  @override
  Future<void> setUserRole({
    required String uid,
    required UserRoleValue role,
  }) => _call('setUserRole', {'uid': uid, 'role': role.name});

  @override
  Future<List<Report>> getOpenReports({int limit = 30}) async {
    final snap = await _db
        .collection('reports')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return Report(
        id: d.id,
        listingId: (m['listingId'] ?? '') as String,
        reporterId: (m['reporterId'] ?? '') as String,
        reason: (m['reason'] ?? '') as String,
        details: (m['details'] ?? '') as String,
        status: (m['status'] ?? 'open') as String,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required bool removeListing,
  }) => _call('resolveReport', {
    'reportId': reportId,
    'removeListing': removeListing,
  });

  @override
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 50}) async {
    final snap = await _db
        .collection('admin_logs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return AuditLogEntry(
        id: d.id,
        actorId: (m['actorId'] ?? '') as String,
        action: (m['action'] ?? '') as String,
        targetId: (m['targetId'] ?? '') as String,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}

/// Firestore-backed report submission.
class FirestoreReportRepository implements ReportRepository {
  FirestoreReportRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<void> submit({
    required String listingId,
    required String reporterId,
    required String reason,
    required String details,
  }) =>
      // Deterministic id: one report per user per listing.
      _db.collection('reports').doc('${listingId}_$reporterId').set({
        'listingId': listingId,
        'reporterId': reporterId,
        'reason': reason,
        'details': details.trim(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
}
