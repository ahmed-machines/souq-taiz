import '../entities/location.dart';

abstract interface class LocationRepository {
  Future<List<Location>> getAll();
  Future<void> upsert(Location location);
  Future<void> deactivate(String locationId);
}
