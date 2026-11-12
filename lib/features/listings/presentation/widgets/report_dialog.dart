import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../shared/providers/repository_providers.dart';

/// Dialog for reporting a listing. One report per user per listing.
Future<void> showReportDialog(
  BuildContext context,
  WidgetRef ref, {
  required String listingId,
  required String reporterId,
}) async {
  final l10n = AppLocalizations.of(context);
  final reasons = {
    'spam': l10n.reasonSpam,
    'prohibited': l10n.reasonProhibited,
    'fraud': l10n.reasonFraud,
    'other': l10n.reasonOther,
  };
  var reason = 'spam';
  final details = TextEditingController();

  final send = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l10n.reportListing),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: reason,
              decoration: InputDecoration(labelText: l10n.reportReason),
              items: [
                for (final e in reasons.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => reason = v ?? reason),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: details,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(labelText: l10n.reportDetails),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.submit),
          ),
        ],
      ),
    ),
  );
  final text = details.text;
  details.dispose();
  if (send != true || !context.mounted) return;
  try {
    await ref
        .read(reportRepositoryProvider)
        .submit(
          listingId: listingId,
          reporterId: reporterId,
          reason: reason,
          details: text,
        );
    if (context.mounted) showToast(context, l10n.reportSent);
  } catch (e) {
    if (context.mounted) {
      showToast(context, FailureMapper.from(e).message(l10n));
    }
  }
}
