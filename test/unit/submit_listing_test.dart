import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/core/errors/failure.dart';
import 'package:souq_taiz/core/result/result.dart';
import 'package:souq_taiz/features/authentication/domain/entities/app_user.dart';
import 'package:souq_taiz/features/listings/domain/entities/listing.dart';
import 'package:souq_taiz/features/listings/domain/usecases/listing_input.dart';
import 'package:souq_taiz/features/listings/domain/usecases/submit_listing.dart';
import 'package:souq_taiz/shared/mock/mock_repositories.dart';

class _FakeUploader implements ListingImageUploader {
  int calls = 0;
  List<PickedImage> received = [];

  @override
  Future<List<String>> upload({
    required String ownerId,
    required String listingId,
    required List<PickedImage> images,
  }) async {
    calls++;
    received = images;
    return [
      for (var i = 0; i < images.length; i++) 'https://img/$listingId/$i',
    ];
  }
}

const _owner = AppUser(
  uid: 'owner1',
  email: 'o@o.co',
  displayName: 'Owner',
  role: UserRole.buyer,
  status: AccountStatus.active,
  emailVerified: true,
);

ListingInput _input({String title = 'Toyota Corolla', num? price = 1000}) =>
    ListingInput(
      title: title,
      description: 'A long enough description',
      categoryId: 'cars',
      locationId: 'taiz',
      price: price,
      priceType: PriceType.fixed,
      contactPhone: '777123456',
    );

PickedImage _img(String n) =>
    PickedImage(name: n, bytes: Uint8List.fromList([1, 2, 3]));

void main() {
  late MockListingRepository repo;
  late _FakeUploader uploader;
  late SubmitListing useCase;

  setUp(() {
    repo = MockListingRepository();
    uploader = _FakeUploader();
    useCase = SubmitListing(repo, uploader);
  });

  test('creates a pending-review listing, uploading images in order', () async {
    final result = await useCase(
      owner: _owner,
      input: _input(),
      images: [LocalImage(_img('a.jpg')), LocalImage(_img('b.png'))],
    );
    final listing = (result as Success<Listing>).value;
    expect(listing.status, ListingStatus.pendingReview);
    expect(listing.ownerId, 'owner1');
    expect(listing.imageUrls.length, 2);
    expect(listing.coverImageUrl, endsWith('/0'));
    expect(uploader.received.map((e) => e.name), ['a.jpg', 'b.png']);
    expect(await repo.getById(listing.id), isNotNull);
  });

  test(
    'keeps existing remote images and the chosen order when editing',
    () async {
      final created =
          ((await useCase(
                    owner: _owner,
                    input: _input(),
                    images: [LocalImage(_img('a.jpg'))],
                  ))
                  as Success<Listing>)
              .value;
      final edited = await useCase(
        owner: _owner,
        existingId: created.id,
        existingCreatedAt: created.createdAt,
        input: _input(title: 'Updated title'),
        images: [
          LocalImage(_img('new.jpg')),
          RemoteImage(created.imageUrls.first),
        ],
      );
      final l = (edited as Success<Listing>).value;
      expect(l.title, 'Updated title');
      expect(l.imageUrls.length, 2);
      expect(l.imageUrls[1], created.imageUrls.first);
      expect(l.status, ListingStatus.pendingReview);
    },
  );

  test('invalid input fails validation without uploading', () async {
    final result = await useCase(
      owner: _owner,
      input: _input(price: 0),
      images: [LocalImage(_img('a.jpg'))],
    );
    expect((result as Err<Listing>).failure.type, FailureType.validation);
    expect(uploader.calls, 0);
  });

  test('requires at least one image and at most the maximum', () async {
    expect(
      ListingValidator.validate(
        _input(),
        imageCount: 0,
      ).containsKey(ListingField.images),
      isTrue,
    );
    expect(
      ListingValidator.validate(
        _input(),
        imageCount: 9,
      ).containsKey(ListingField.images),
      isTrue,
    );
    expect(ListingValidator.validate(_input(), imageCount: 3), isEmpty);
  });

  test('suspended accounts cannot publish', () async {
    const suspended = AppUser(
      uid: 's',
      email: 's@s.co',
      displayName: 'S',
      role: UserRole.buyer,
      status: AccountStatus.suspended,
      emailVerified: true,
    );
    final result = await useCase(
      owner: suspended,
      input: _input(),
      images: [LocalImage(_img('a.jpg'))],
    );
    expect((result as Err<Listing>).failure.type, FailureType.accountSuspended);
  });
}
