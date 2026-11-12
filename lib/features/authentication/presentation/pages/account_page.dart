import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../domain/entities/app_user.dart';
import '../controllers/auth_controller.dart';

/// Account overview: profile, email verification, suspension notice, logout.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  String _role(AppLocalizations l, UserRole r) => switch (r) {
    UserRole.admin => l.roleAdmin,
    UserRole.superAdmin => l.roleSuperAdmin,
    UserRole.seller => l.roleSeller,
    _ => l.roleBuyer,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(user.email),
          Text('${l10n.accountRole}: ${_role(l10n, user.role)}'),
          const SizedBox(height: AppSpacing.md),
          if (!user.emailVerified)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                title: Text(l10n.verifyEmailBanner),
                trailing: TextButton(
                  onPressed: () async {
                    final failure = await ref
                        .read(authControllerProvider.notifier)
                        .resendVerification();
                    if (context.mounted) {
                      showToast(
                        context,
                        failure?.message(l10n) ?? l10n.verificationSent,
                      );
                    }
                  },
                  child: Text(l10n.resendVerification),
                ),
              ),
            ),
          if (!user.isActive)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(title: Text(l10n.suspendedBanner)),
            ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
