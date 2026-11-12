import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../domain/entities/location.dart';

final locationsProvider = FutureProvider<List<Location>>(
  (ref) => ref.watch(locationRepositoryProvider).getAll(),
);

/// Selected location filter shared by the header selector and search.
class SelectedLocation extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedLocationProvider = NotifierProvider<SelectedLocation, String?>(
  SelectedLocation.new,
);
