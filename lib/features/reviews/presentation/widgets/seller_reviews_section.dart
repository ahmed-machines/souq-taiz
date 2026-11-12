import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../authentication/domain/entities/app_user.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/review_providers.dart';

/// Approved reviews of a seller plus a form to add one.
class SellerReviewsSection extends ConsumerWidget {
  const SellerReviewsSection({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final user = ref.watch(currentUserProvider);
    final reviews = ref.watch(sellerReviewsProvider(sellerId));
    final canReview =
        user != null &&
        user.isActive &&
        user.emailVerified &&
        user.uid != sellerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.reviewsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (canReview)
              TextButton(
                onPressed: () => _write(context, ref, user),
                child: Text(l10n.writeReview),
              ),
          ],
        ),
        reviews.when(
          loading: () => const SkeletonBox(height: 48),
          error: (_, _) => ErrorState(
            message: l10n.errUnknown,
            onRetry: () => ref.invalidate(sellerReviewsProvider(sellerId)),
          ),
          data: (items) => items.isEmpty
              ? Text(l10n.noReviews)
              : Column(
                  children: [
                    for (final r in items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Text(r.reviewerName),
                            const SizedBox(width: AppSpacing.sm),
                            for (var i = 0; i < r.rating; i++)
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${r.text}\n${DateFormat.yMMMd(lang).format(r.createdAt)}',
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _write(BuildContext context, WidgetRef ref, AppUser user) async {
    final l10n = AppLocalizations.of(context);
    var rating = 5;
    final text = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.writeReview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: '$i',
                      icon: Icon(
                        i <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => rating = i),
                    ),
                ],
              ),
              TextField(
                controller: text,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(labelText: l10n.reviewText),
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
    final comment = text.text;
    text.dispose();
    if (ok != true || !context.mounted) return;
    final result = await ref
        .read(reviewRepositoryProvider)
        .submit(
          sellerId: sellerId,
          reviewerId: user.uid,
          reviewerName: user.displayName,
          rating: rating,
          text: comment,
        );
    if (!context.mounted) return;
    showToast(
      context,
      result.when(
        success: (_) => l10n.reviewSubmitted,
        failure: (f) => f.message(l10n),
      ),
    );
  }
}
