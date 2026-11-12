abstract interface class FavoritesRepository {
  /// Live set of favorited listing ids for [uid] (bounded by [limit]).
  Stream<Set<String>> watchIds(String uid, {int limit = 200});

  /// Idempotent: the document id is the listing id, so duplicates are impossible.
  Future<void> add(String uid, String listingId);
  Future<void> remove(String uid, String listingId);
}
