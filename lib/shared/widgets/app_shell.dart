import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/generated/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../providers/firebase_providers.dart';
import 'app_header.dart';

/// Shell for all public and authenticated pages.
/// Renders the [AppHeader], an optional demo-mode banner, and the [child].
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = !ref.watch(firebaseReadyProvider);
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          if (demo) const _DemoBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.12),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppLocalizations.of(context).demoBanner,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
