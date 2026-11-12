import 'package:flutter/foundation.dart';

import '../../../../core/validators/validators.dart';
import '../entities/listing.dart';

/// Image picked on the device, not yet uploaded.
@immutable
class PickedImage {
  const PickedImage({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// An entry in the ordered image list of the listing form.
sealed class ListingImage {
  const ListingImage();
}

final class RemoteImage extends ListingImage {
  const RemoteImage(this.url);
  final String url;
}

final class LocalImage extends ListingImage {
  const LocalImage(this.picked);
  final PickedImage picked;
}

/// Uploads images to storage and returns download URLs in the same order.
abstract interface class ListingImageUploader {
  Future<List<String>> upload({
    required String ownerId,
    required String listingId,
    required List<PickedImage> images,
  });
}

/// Form values for creating/editing a listing.
@immutable
class ListingInput {
  const ListingInput({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.locationId,
    required this.price,
    required this.priceType,
    required this.contactPhone,
    this.subcategoryId,
  });

  final String title;
  final String description;
  final String? categoryId;
  final String? subcategoryId;
  final String? locationId;
  final num? price;
  final PriceType priceType;
  final String contactPhone;
}

enum ListingField {
  title,
  description,
  category,
  location,
  price,
  phone,
  images,
}

/// Validates listing input and returns per-field errors (empty = valid).
abstract final class ListingValidator {
  static Map<ListingField, ValidationError> validate(
    ListingInput i, {
    required int imageCount,
  }) {
    final errors = <ListingField, ValidationError>{};
    void check(ListingField f, ValidationError? e) {
      if (e != null) errors[f] = e;
    }

    check(ListingField.title, Validators.title(i.title));
    check(ListingField.description, Validators.description(i.description));
    check(
      ListingField.category,
      i.categoryId == null ? ValidationError.required : null,
    );
    check(
      ListingField.location,
      i.locationId == null ? ValidationError.required : null,
    );
    check(ListingField.price, Validators.price(i.price));
    check(ListingField.phone, Validators.phone(i.contactPhone));
    if (imageCount == 0) {
      errors[ListingField.images] = ValidationError.noImages;
    } else if (imageCount > Validators.maxImages) {
      errors[ListingField.images] = ValidationError.tooManyImages;
    }
    return errors;
  }
}
