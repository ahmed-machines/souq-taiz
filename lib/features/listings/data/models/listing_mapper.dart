import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../search/domain/keyword_tokenizer.dart';
import '../../domain/entities/listing.dart';

/// Maps between Firestore documents and [Listing].
abstract final class ListingMapper {
  static Listing fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? const <String, dynamic>{};
    return Listing(
      id: doc.id,
      ownerId: (m['ownerId'] ?? '') as String,
      ownerName: (m['ownerName'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      categoryId: (m['categoryId'] ?? '') as String,
      subcategoryId: m['subcategoryId'] as String?,
      locationId: (m['locationId'] ?? '') as String,
      price: (m['price'] ?? 0) as num,
      currency: (m['currency'] ?? 'YER') as String,
      priceType: PriceType.parse(m['priceType'] as String?),
      imageUrls: List<String>.from(
        (m['imageUrls'] ?? const <String>[]) as List,
      ),
      contactPhone: (m['contactPhone'] ?? '') as String,
      status: ListingStatus.parse(m['status'] as String?),
      isFeatured: (m['isFeatured'] ?? false) as bool,
      rejectionReason: m['rejectionReason'] as String?,
      createdAt: _date(m['createdAt']) ?? DateTime.now(),
      updatedAt: _date(m['updatedAt']),
      viewCount: (m['viewCount'] ?? 0) as int,
    );
  }

  /// Fields written on create. Server-owned fields get safe initial values;
  /// security rules reject any other values.
  static Map<String, dynamic> toCreateMap(Listing l) => {
    ..._content(l),
    'status': l.status.value,
    'isFeatured': false,
    'viewCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Only owner-editable fields.
  static Map<String, dynamic> toUpdateMap(Listing l) => {
    ..._content(l),
    'status': l.status.value,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> _content(Listing l) => {
    'ownerId': l.ownerId,
    'ownerName': l.ownerName,
    'title': l.title.trim(),
    'description': l.description.trim(),
    'categoryId': l.categoryId,
    'subcategoryId': l.subcategoryId,
    'locationId': l.locationId,
    'price': l.price,
    'currency': l.currency,
    'priceType': l.priceType.value,
    'imageUrls': l.imageUrls,
    'coverImageUrl': l.coverImageUrl,
    'contactPhone': l.contactPhone,
    'searchKeywords': KeywordTokenizer.tokens(l.title),
  };

  static DateTime? _date(Object? v) => v is Timestamp ? v.toDate() : null;
}
