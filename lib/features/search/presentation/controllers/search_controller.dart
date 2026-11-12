import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/search_query.dart';

/// Search results state with cursor-based pagination.
class SearchState {
  const SearchState({
    this.query = const SearchQuery(),
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final SearchQuery query;
  final List<Listing> items;
  final Object? cursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;

  SearchState copyWith({
    SearchQuery? query,
    List<Listing>? items,
    Object? cursor,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) => SearchState(
    query: query ?? this.query,
    items: items ?? this.items,
    cursor: cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

class ListingSearchController extends Notifier<SearchState> {
  static const int pageSize = 20;

  @override
  SearchState build() => const SearchState();

  /// Replaces the query and loads the first page.
  Future<void> setQuery(SearchQuery query) async {
    state = SearchState(query: query, isLoading: true);
    await _fetch(first: true);
  }

  Future<void> refresh() => setQuery(state.query);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true, clearFailure: true);
    await _fetch(first: false);
  }

  Future<void> _fetch({required bool first}) async {
    final requested = state.query;
    try {
      final page = await ref
          .read(searchServiceProvider)
          .search(
            requested,
            cursor: first ? null : state.cursor,
            limit: pageSize,
          );
      if (state.query != requested) return; // superseded by a newer query
      state = state.copyWith(
        items: first ? page.items : [...state.items, ...page.items],
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoading: false,
        isLoadingMore: false,
        clearFailure: true,
      );
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        failure: FailureMapper.from(e, st),
      );
    }
  }
}

final searchControllerProvider =
    NotifierProvider<ListingSearchController, SearchState>(
      ListingSearchController.new,
    );
