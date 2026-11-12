import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

/// Live favorite ids of the signed-in user (empty when signed out).
final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const <String>{});
  return ref.watch(favoritesRepositoryProvider).watchIds(user.uid);
});

final isFavoriteProvider = Provider.family<bool, String>(
  (ref, listingId) =>
      ref.watch(favoriteIdsProvider).value?.contains(listingId) ?? false,
);

class FavoritesController extends Notifier<void> {
  @override
  void build() {}

  /// Toggles favorite. Returns false when the user is not signed in.
  Future<bool> toggle(String listingId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    final repo = ref.read(favoritesRepositoryProvider);
    final isFav = ref.read(isFavoriteProvider(listingId));
    await (isFav
        ? repo.remove(user.uid, listingId)
        : repo.add(user.uid, listingId));
    return true;
  }
}

final favoritesControllerProvider = NotifierProvider<FavoritesController, void>(
  FavoritesController.new,
);
