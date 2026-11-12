import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/usecases/listing_input.dart';

/// Firebase Storage uploader. Path: `listings/{ownerId}/{listingId}/{n}_{ts}.{ext}`.
/// Storage rules re-validate owner, content type and size server-side.
class FirebaseListingImageUploader implements ListingImageUploader {
  FirebaseListingImageUploader(this._storage);

  final FirebaseStorage _storage;

  static const _contentTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  @override
  Future<List<String>> upload({
    required String ownerId,
    required String listingId,
    required List<PickedImage> images,
  }) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];
    for (var i = 0; i < images.length; i++) {
      final ext = images[i].name.split('.').last.toLowerCase();
      final ref = _storage.ref('listings/$ownerId/$listingId/${stamp}_$i.$ext');
      await ref.putData(
        images[i].bytes,
        SettableMetadata(contentType: _contentTypes[ext] ?? 'image/jpeg'),
      );
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }
}
