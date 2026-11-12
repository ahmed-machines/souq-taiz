"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMessageCreated = exports.resolveReport = exports.setUserRole = exports.setUserSuspended = exports.setFeatured = exports.moderateListing = void 0;
const app_1 = require("firebase-admin/app");
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const firestore_2 = require("firebase-functions/v2/firestore");
const https_1 = require("firebase-functions/v2/https");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
/** Loads the caller's role from Firestore (never from client input). */
async function requireAdmin(auth, superOnly = false) {
    if (!auth)
        throw new https_1.HttpsError('unauthenticated', 'Sign in required');
    const snap = await db.doc(`users/${auth.uid}`).get();
    const data = snap.data();
    const role = data?.role;
    const isAdmin = role === 'admin' || role === 'super_admin';
    if (!data || data.status !== 'active' || !isAdmin || (superOnly && role !== 'super_admin')) {
        throw new https_1.HttpsError('permission-denied', 'Insufficient privileges');
    }
    return { uid: auth.uid, role: role };
}
function str(v, name, max = 200) {
    if (typeof v !== 'string' || v.length === 0 || v.length > max) {
        throw new https_1.HttpsError('invalid-argument', `Invalid ${name}`);
    }
    return v;
}
async function audit(actorId, action, targetType, targetId, details = {}) {
    await db.collection('admin_logs').add({
        actorId,
        action,
        targetType,
        targetId,
        details,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    });
}
async function notify(uid, data, id) {
    const col = db.collection(`users/${uid}/notifications`);
    const ref = id ? col.doc(id) : col.doc();
    await ref.set({ ...data, read: false, createdAt: firestore_1.FieldValue.serverTimestamp() });
}
exports.moderateListing = (0, https_1.onCall)(async (req) => {
    const admin = await requireAdmin(req.auth);
    const listingId = str(req.data?.listingId, 'listingId');
    const approve = req.data?.approve === true;
    const reason = approve ? null : str(req.data?.reason ?? 'Policy violation', 'reason', 300);
    const ref = db.doc(`listings/${listingId}`);
    const snap = await ref.get();
    if (!snap.exists)
        throw new https_1.HttpsError('not-found', 'Listing not found');
    const listing = snap.data();
    if (listing.status !== 'pending_review') {
        throw new https_1.HttpsError('failed-precondition', 'Listing is not pending review');
    }
    await ref.update({
        status: approve ? 'published' : 'rejected',
        rejectionReason: reason,
        updatedAt: firestore_1.FieldValue.serverTimestamp(),
    });
    await notify(listing.ownerId, {
        type: approve ? 'listing_approved' : 'listing_rejected',
        listingId,
        listingTitle: listing.title,
        reason,
    });
    await audit(admin.uid, approve ? 'listing_approved' : 'listing_rejected', 'listing', listingId, { reason });
    return { ok: true };
});
exports.setFeatured = (0, https_1.onCall)(async (req) => {
    const admin = await requireAdmin(req.auth);
    const listingId = str(req.data?.listingId, 'listingId');
    const featured = req.data?.featured === true;
    await db.doc(`listings/${listingId}`).update({ isFeatured: featured, updatedAt: firestore_1.FieldValue.serverTimestamp() });
    await audit(admin.uid, featured ? 'listing_featured' : 'listing_unfeatured', 'listing', listingId);
    return { ok: true };
});
exports.setUserSuspended = (0, https_1.onCall)(async (req) => {
    const admin = await requireAdmin(req.auth);
    const uid = str(req.data?.uid, 'uid', 128);
    const suspended = req.data?.suspended === true;
    if (uid === admin.uid)
        throw new https_1.HttpsError('failed-precondition', 'Cannot change own status');
    const target = (await db.doc(`users/${uid}`).get()).data();
    if (!target)
        throw new https_1.HttpsError('not-found', 'User not found');
    const targetIsAdmin = target.role === 'admin' || target.role === 'super_admin';
    // Admins cannot act on other admins; only a super admin can.
    if (targetIsAdmin && admin.role !== 'super_admin') {
        throw new https_1.HttpsError('permission-denied', 'Insufficient privileges');
    }
    if (target.role === 'super_admin')
        throw new https_1.HttpsError('permission-denied', 'Cannot suspend a super admin');
    await db.doc(`users/${uid}`).update({ status: suspended ? 'suspended' : 'active' });
    await (0, auth_1.getAuth)().updateUser(uid, { disabled: suspended });
    await notify(uid, { type: 'account_status' });
    await audit(admin.uid, suspended ? 'user_suspended' : 'user_unsuspended', 'user', uid);
    return { ok: true };
});
exports.setUserRole = (0, https_1.onCall)(async (req) => {
    const admin = await requireAdmin(req.auth, true);
    const uid = str(req.data?.uid, 'uid', 128);
    const role = req.data?.role;
    if (!['buyer', 'seller', 'admin'].includes(role))
        throw new https_1.HttpsError('invalid-argument', 'Invalid role');
    if (uid === admin.uid)
        throw new https_1.HttpsError('failed-precondition', 'Cannot change own role');
    const target = (await db.doc(`users/${uid}`).get()).data();
    if (!target)
        throw new https_1.HttpsError('not-found', 'User not found');
    if (target.role === 'super_admin')
        throw new https_1.HttpsError('permission-denied', 'Cannot change a super admin');
    await db.doc(`users/${uid}`).update({ role });
    await audit(admin.uid, 'user_role_changed', 'user', uid, { role });
    return { ok: true };
});
exports.resolveReport = (0, https_1.onCall)(async (req) => {
    const admin = await requireAdmin(req.auth);
    const reportId = str(req.data?.reportId, 'reportId');
    const removeListing = req.data?.removeListing === true;
    const ref = db.doc(`reports/${reportId}`);
    const report = (await ref.get()).data();
    if (!report)
        throw new https_1.HttpsError('not-found', 'Report not found');
    if (removeListing) {
        await db.doc(`listings/${report.listingId}`).update({
            status: 'archived',
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
        });
    }
    await ref.update({
        status: removeListing ? 'actioned' : 'dismissed',
        resolvedBy: admin.uid,
        resolvedAt: firestore_1.FieldValue.serverTimestamp(),
    });
    await audit(admin.uid, removeListing ? 'report_actioned' : 'report_dismissed', 'report', reportId, {
        listingId: report.listingId,
    });
    return { ok: true };
});
const MAX_MESSAGES_PER_MINUTE = 20;
/** Notifies the recipient of a new message and rate-limits abusive senders. */
exports.onMessageCreated = (0, firestore_2.onDocumentCreated)('conversations/{conversationId}/messages/{messageId}', async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const message = snap.data();
    const { conversationId } = event.params;
    const since = new Date(Date.now() - 60_000);
    const recent = await db
        .collection(`conversations/${conversationId}/messages`)
        .where('senderId', '==', message.senderId)
        .where('createdAt', '>', since)
        .count()
        .get();
    if (recent.data().count > MAX_MESSAGES_PER_MINUTE) {
        await snap.ref.delete();
        return;
    }
    const conv = (await db.doc(`conversations/${conversationId}`).get()).data();
    const recipient = conv?.participantIds?.find((p) => p !== message.senderId);
    if (!recipient)
        return;
    // One rolling notification per conversation.
    await notify(recipient, { type: 'new_message', listingId: conv?.listingId, listingTitle: conv?.listingTitle }, `msg_${conversationId}`);
});
