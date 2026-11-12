// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Souq Taiz';

  @override
  String get tagline => 'Your local market.. everything closer to you';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get close => 'Close';

  @override
  String get submit => 'Submit';

  @override
  String get seeAll => 'See all';

  @override
  String get add => 'Add';

  @override
  String get noData => 'No data';

  @override
  String get loadMore => 'Load more';

  @override
  String get errNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get errUnauthenticated => 'Please sign in to continue.';

  @override
  String get errPermission => 'You do not have permission to do this.';

  @override
  String get errNotFound => 'The requested item was not found.';

  @override
  String get errValidation => 'Please correct the entered data.';

  @override
  String get errConfiguration =>
      'Service not configured yet (Firebase). See docs/setup/firebase-setup.md';

  @override
  String get errInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errEmailInUse => 'This email is already registered.';

  @override
  String get errWeakPassword => 'The password is too weak.';

  @override
  String get errSuspended => 'This account has been suspended.';

  @override
  String get errTooMany => 'Too many attempts. Try again later.';

  @override
  String get errUnknown => 'An unexpected error occurred.';

  @override
  String get vRequired => 'This field is required';

  @override
  String get vEmail => 'Invalid email address';

  @override
  String get vPassword => 'At least 8 characters with a letter and a digit';

  @override
  String get vPasswordMismatch => 'Passwords do not match';

  @override
  String get vPhone => 'Invalid Yemeni mobile number (e.g. 777123456)';

  @override
  String get vTooShort => 'Text is too short';

  @override
  String get vTooLong => 'Text is too long';

  @override
  String get vPrice => 'Enter a valid price greater than zero';

  @override
  String get vPriceHigh => 'Price is too high';

  @override
  String get vTooManyImages => 'Maximum 8 images';

  @override
  String get vNoImages => 'Add at least one image';

  @override
  String get vImageType => 'Unsupported image type (JPG, PNG or WEBP)';

  @override
  String get vImageSize => 'Image exceeds 5 MB';

  @override
  String get vRating => 'Choose a rating from 1 to 5';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navMessages => 'Messages';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSell => 'Post an ad';

  @override
  String get navDashboard => 'Seller dashboard';

  @override
  String get navAccount => 'My account';

  @override
  String get navAdmin => 'Admin';

  @override
  String get login => 'Sign in';

  @override
  String get register => 'Sign up';

  @override
  String get logout => 'Sign out';

  @override
  String get searchHint => 'Search cars, phones, real estate...';

  @override
  String get allLocations => 'All locations';

  @override
  String get demoBanner => 'Demo mode: sample data, not connected to Firebase';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homePopularCategories => 'Popular categories';

  @override
  String get homeFeatured => 'Featured listings';

  @override
  String get homeLatest => 'Latest listings';

  @override
  String get homeRecommended => 'Recommended for you';

  @override
  String get homeFeaturedShops => 'Featured shops';

  @override
  String get homeFeaturedShopsEmpty => 'Featured shops will appear here soon.';

  @override
  String get homeBannerTitle => 'Buy and sell in Taiz with ease';

  @override
  String get homeBannerBody =>
      'Post your ad for free and contact buyers directly.';

  @override
  String get footerAbout => 'About Souq Taiz';

  @override
  String get footerHelp => 'Help';

  @override
  String get footerTerms => 'Terms';

  @override
  String get footerPrivacy => 'Privacy';

  @override
  String get footerContact => 'Contact us';

  @override
  String get footerRights => 'All rights reserved';

  @override
  String get filters => 'Filters';

  @override
  String get category => 'Category';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get location => 'Location';

  @override
  String get allOption => 'All';

  @override
  String get minPrice => 'Min price';

  @override
  String get maxPrice => 'Max price';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortPriceLow => 'Lowest price';

  @override
  String get sortPriceHigh => 'Highest price';

  @override
  String get featuredOnly => 'Featured only';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get searchEmpty => 'No listings match your search.';

  @override
  String get price => 'Price';

  @override
  String get negotiable => 'Negotiable';

  @override
  String get fixedPrice => 'Fixed price';

  @override
  String get description => 'Description';

  @override
  String get seller => 'Seller';

  @override
  String get publishedOn => 'Published';

  @override
  String get contactWhatsApp => 'Contact via WhatsApp';

  @override
  String get callSeller => 'Call';

  @override
  String get chatWithSeller => 'Message seller';

  @override
  String get reportListing => 'Report listing';

  @override
  String get relatedListings => 'Related listings';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get noImage => 'No image';

  @override
  String get loginRequired => 'Sign in to continue';

  @override
  String get listingNotFound => 'Listing not found or unavailable.';

  @override
  String waMessage(String title) {
    return 'Hello, I am interested in your Souq Taiz listing: $title';
  }

  @override
  String get reportReason => 'Reason';

  @override
  String get reportDetails => 'Additional details (optional)';

  @override
  String get reportSent => 'Report sent. Thank you.';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get reasonProhibited => 'Prohibited content';

  @override
  String get reasonFraud => 'Fraud';

  @override
  String get reasonOther => 'Other';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Mobile number';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetSent => 'A password reset link was sent to your email.';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get verifyEmailBanner =>
      'Please verify your email. A verification message was sent.';

  @override
  String get resendVerification => 'Resend verification';

  @override
  String get verificationSent => 'Verification email sent.';

  @override
  String get suspendedBanner =>
      'Your account is suspended; you cannot post or message.';

  @override
  String get accountRole => 'Role';

  @override
  String get createListing => 'Create listing';

  @override
  String get editListing => 'Edit listing';

  @override
  String get listingTitle => 'Listing title';

  @override
  String get priceLabel => 'Price (YER)';

  @override
  String get priceType => 'Price type';

  @override
  String get contactPhone => 'Contact number (WhatsApp)';

  @override
  String get images => 'Images';

  @override
  String get addImages => 'Add images';

  @override
  String get imagesHint =>
      'The first image is the cover. Drag to reorder. Up to 8 images, 5 MB each.';

  @override
  String get setCover => 'Set as cover';

  @override
  String get removeImage => 'Remove image';

  @override
  String get coverBadge => 'Cover';

  @override
  String get submitForReview => 'Submit for review';

  @override
  String get listingSubmitted => 'Listing submitted for review.';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPending => 'Pending review';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusSold => 'Sold';

  @override
  String get statusArchived => 'Archived';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get markSold => 'Mark as sold';

  @override
  String get deleteListing => 'Delete listing';

  @override
  String get deleteConfirm => 'Delete this listing? It will be archived.';

  @override
  String get sellerDashboard => 'Seller dashboard';

  @override
  String get totalListings => 'Total listings';

  @override
  String get myListings => 'My listings';

  @override
  String get noListings => 'No listings yet.';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'You have no favorites yet.';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No conversations.';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get messageRead => 'Read';

  @override
  String get messageSent => 'Sent';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications.';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get ntfApproved => 'Your listing was approved and published';

  @override
  String get ntfRejected => 'Your listing was rejected';

  @override
  String get ntfNewMessage => 'You have a new message';

  @override
  String get ntfStatus => 'Your listing status was updated';

  @override
  String get ntfAccount => 'Your account status was updated';

  @override
  String get reviewsTitle => 'Seller reviews';

  @override
  String get noReviews => 'No reviews yet.';

  @override
  String get writeReview => 'Write a review';

  @override
  String get reviewText => 'Your comment (optional)';

  @override
  String get reviewSubmitted =>
      'Review submitted; it will appear after moderation.';

  @override
  String get adminTitle => 'Admin';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get adminModeration => 'Moderation';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminReports => 'Reports';

  @override
  String get adminCategories => 'Categories';

  @override
  String get adminLocations => 'Locations';

  @override
  String get adminLogs => 'Audit log';

  @override
  String get statUsers => 'Users';

  @override
  String get statPending => 'Pending';

  @override
  String get statPublished => 'Published';

  @override
  String get statRejected => 'Rejected';

  @override
  String get statSold => 'Sold';

  @override
  String get statOpenReports => 'Open reports';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectReasonHint => 'Reason for rejection';

  @override
  String get suspend => 'Suspend';

  @override
  String get unsuspend => 'Unsuspend';

  @override
  String get feature => 'Feature';

  @override
  String get unfeature => 'Unfeature';

  @override
  String get dismissReport => 'Dismiss';

  @override
  String get removeListing => 'Remove listing';

  @override
  String get nameAr => 'Arabic name';

  @override
  String get nameEn => 'English name';

  @override
  String get roleBuyer => 'Buyer';

  @override
  String get roleSeller => 'Seller';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleSuperAdmin => 'Super admin';

  @override
  String get actionDone => 'Done';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get backToHome => 'Back to home';
}
