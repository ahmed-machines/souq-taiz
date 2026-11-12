import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';

/// Heart toggle. Redirects guests to login.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFav = ref.watch(isFavoriteProvider(listingId));
    return IconButton(
      tooltip: isFav ? l10n.removeFavorite : l10n.addFavorite,
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : null,
      ),
      onPressed: () async {
        if (ref.read(currentUserProvider) == null) {
          showToast(context, l10n.loginRequired);
          context.go(RouteNames.login);
          return;
        }
        try {
          await ref
              .read(favoritesControllerProvider.notifier)
              .toggle(listingId);
        } catch (_) {
          if (context.mounted) showToast(context, l10n.errUnknown);
        }
      },
    );
  }
}
