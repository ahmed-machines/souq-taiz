import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../authentication/domain/entities/app_user.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';
import 'listing_input.dart';

/// Creates or edits a listing: validates, uploads new images, then saves.
/// New and edited listings always go to `pendingReview` for moderation.
class SubmitListing {
  SubmitListing(this._repo, this._uploader);

  final ListingRepository _repo;
  final ListingImageUploader _uploader;

  Future<Result<Listing>> call({
    required AppUser owner,
    required ListingInput input,
    required List<ListingImage> images,
    String? existingId,
    DateTime? existingCreatedAt,
  }) async {
    if (!owner.canPublish) {
      return const Err(Failure(FailureType.accountSuspended));
    }
    if (ListingValidator.validate(
      input,
      imageCount: images.length,
    ).isNotEmpty) {
      return const Err(Failure(FailureType.validation));
    }
    try {
      final id = existingId ?? _repo.newId();
      final locals = images
          .whereType<LocalImage>()
          .map((i) => i.picked)
          .toList();
      final uploaded = locals.isEmpty
          ? const <String>[]
          : await _uploader.upload(
              ownerId: owner.uid,
              listingId: id,
              images: locals,
            );
      var next = 0;
      final urls = [
        for (final img in images)
          switch (img) {
            RemoteImage(:final url) => url,
            LocalImage() => uploaded[next++],
          },
      ];
      final listing = Listing(
        id: id,
        ownerId: owner.uid,
        ownerName: owner.displayName,
        title: input.title.trim(),
        description: input.description.trim(),
        categoryId: input.categoryId!,
        subcategoryId: input.subcategoryId,
        locationId: input.locationId!,
        price: input.price!,
        priceType: input.priceType,
        imageUrls: urls,
        contactPhone: input.contactPhone.trim(),
        status: ListingStatus.pendingReview,
        createdAt: existingCreatedAt ?? DateTime.now(),
      );
      existingId == null
          ? await _repo.create(listing)
          : await _repo.update(listing);
      return Success(listing);
    } catch (e, st) {
      return Err(FailureMapper.from(e, st));
    }
  }
}
