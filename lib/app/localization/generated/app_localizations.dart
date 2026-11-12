import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سوق تعز'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'سوقك المحلي.. كل شيء أقرب إليك'**
  String get tagline;

  /// No description provided for @switchLanguage.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get switchLanguage;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get seeAll;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @loadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get loadMore;

  /// No description provided for @errNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالشبكة. تحقق من الإنترنت وحاول مجدداً.'**
  String get errNetwork;

  /// No description provided for @errUnauthenticated.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول للمتابعة.'**
  String get errUnauthenticated;

  /// No description provided for @errPermission.
  ///
  /// In ar, this message translates to:
  /// **'ليست لديك صلاحية لتنفيذ هذا الإجراء.'**
  String get errPermission;

  /// No description provided for @errNotFound.
  ///
  /// In ar, this message translates to:
  /// **'العنصر المطلوب غير موجود.'**
  String get errNotFound;

  /// No description provided for @errValidation.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تصحيح البيانات المدخلة.'**
  String get errValidation;

  /// No description provided for @errConfiguration.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة غير مهيأة بعد (Firebase). راجع docs/setup/firebase-setup.md'**
  String get errConfiguration;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة.'**
  String get errInvalidCredentials;

  /// No description provided for @errEmailInUse.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد مسجل مسبقاً.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور ضعيفة.'**
  String get errWeakPassword;

  /// No description provided for @errSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق هذا الحساب.'**
  String get errSuspended;

  /// No description provided for @errTooMany.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. حاول لاحقاً.'**
  String get errTooMany;

  /// No description provided for @errUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع.'**
  String get errUnknown;

  /// No description provided for @vRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get vRequired;

  /// No description provided for @vEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني غير صالح'**
  String get vEmail;

  /// No description provided for @vPassword.
  ///
  /// In ar, this message translates to:
  /// **'8 أحرف على الأقل وتحتوي على حرف ورقم'**
  String get vPassword;

  /// No description provided for @vPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get vPasswordMismatch;

  /// No description provided for @vPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم جوال يمني غير صالح (مثال: 777123456)'**
  String get vPhone;

  /// No description provided for @vTooShort.
  ///
  /// In ar, this message translates to:
  /// **'النص قصير جداً'**
  String get vTooShort;

  /// No description provided for @vTooLong.
  ///
  /// In ar, this message translates to:
  /// **'النص طويل جداً'**
  String get vTooLong;

  /// No description provided for @vPrice.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعراً صحيحاً أكبر من صفر'**
  String get vPrice;

  /// No description provided for @vPriceHigh.
  ///
  /// In ar, this message translates to:
  /// **'السعر مرتفع جداً'**
  String get vPriceHigh;

  /// No description provided for @vTooManyImages.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى 8 صور'**
  String get vTooManyImages;

  /// No description provided for @vNoImages.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة واحدة على الأقل'**
  String get vNoImages;

  /// No description provided for @vImageType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الصورة غير مدعوم (JPG أو PNG أو WEBP)'**
  String get vImageType;

  /// No description provided for @vImageSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الصورة يتجاوز 5 ميجابايت'**
  String get vImageSize;

  /// No description provided for @vRating.
  ///
  /// In ar, this message translates to:
  /// **'اختر تقييماً من 1 إلى 5'**
  String get vRating;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get navFavorites;

  /// No description provided for @navMessages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get navMessages;

  /// No description provided for @navNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get navNotifications;

  /// No description provided for @navSell.
  ///
  /// In ar, this message translates to:
  /// **'أضف إعلانك'**
  String get navSell;

  /// No description provided for @navDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة البائع'**
  String get navDashboard;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @navAdmin.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة'**
  String get navAdmin;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سيارات، جوالات، عقارات...'**
  String get searchHint;

  /// No description provided for @allLocations.
  ///
  /// In ar, this message translates to:
  /// **'كل المواقع'**
  String get allLocations;

  /// No description provided for @demoBanner.
  ///
  /// In ar, this message translates to:
  /// **'وضع العرض التجريبي: بيانات عينة وغير متصل بـ Firebase'**
  String get demoBanner;

  /// No description provided for @homeCategories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get homeCategories;

  /// No description provided for @homePopularCategories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات الشائعة'**
  String get homePopularCategories;

  /// No description provided for @homeFeatured.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات مميزة'**
  String get homeFeatured;

  /// No description provided for @homeLatest.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الإعلانات'**
  String get homeLatest;

  /// No description provided for @homeRecommended.
  ///
  /// In ar, this message translates to:
  /// **'مقترحة لك'**
  String get homeRecommended;

  /// No description provided for @homeFeaturedShops.
  ///
  /// In ar, this message translates to:
  /// **'متاجر مميزة'**
  String get homeFeaturedShops;

  /// No description provided for @homeFeaturedShopsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر المتاجر المميزة هنا قريباً.'**
  String get homeFeaturedShopsEmpty;

  /// No description provided for @homeBannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'بع واشترِ في تعز بسهولة'**
  String get homeBannerTitle;

  /// No description provided for @homeBannerBody.
  ///
  /// In ar, this message translates to:
  /// **'انشر إعلانك مجاناً وتواصل مباشرة مع المشترين.'**
  String get homeBannerBody;

  /// No description provided for @footerAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن سوق تعز'**
  String get footerAbout;

  /// No description provided for @footerHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get footerHelp;

  /// No description provided for @footerTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get footerTerms;

  /// No description provided for @footerPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get footerPrivacy;

  /// No description provided for @footerContact.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get footerContact;

  /// No description provided for @footerRights.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحقوق محفوظة'**
  String get footerRights;

  /// No description provided for @filters.
  ///
  /// In ar, this message translates to:
  /// **'التصفية'**
  String get filters;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get category;

  /// No description provided for @subcategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف الفرعي'**
  String get subcategory;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @allOption.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allOption;

  /// No description provided for @minPrice.
  ///
  /// In ar, this message translates to:
  /// **'أقل سعر'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In ar, this message translates to:
  /// **'أعلى سعر'**
  String get maxPrice;

  /// No description provided for @sortBy.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get sortBy;

  /// No description provided for @sortNewest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ar, this message translates to:
  /// **'الأقدم'**
  String get sortOldest;

  /// No description provided for @sortPriceLow.
  ///
  /// In ar, this message translates to:
  /// **'الأقل سعراً'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى سعراً'**
  String get sortPriceHigh;

  /// No description provided for @featuredOnly.
  ///
  /// In ar, this message translates to:
  /// **'المميزة فقط'**
  String get featuredOnly;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح التصفية'**
  String get clearFilters;

  /// No description provided for @searchEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة لبحثك.'**
  String get searchEmpty;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @negotiable.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتفاوض'**
  String get negotiable;

  /// No description provided for @fixedPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر ثابت'**
  String get fixedPrice;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @seller.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get seller;

  /// No description provided for @publishedOn.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النشر'**
  String get publishedOn;

  /// No description provided for @contactWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'تواصل عبر واتساب'**
  String get contactWhatsApp;

  /// No description provided for @callSeller.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get callSeller;

  /// No description provided for @chatWithSeller.
  ///
  /// In ar, this message translates to:
  /// **'مراسلة البائع'**
  String get chatWithSeller;

  /// No description provided for @reportListing.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن الإعلان'**
  String get reportListing;

  /// No description provided for @relatedListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات مشابهة'**
  String get relatedListings;

  /// No description provided for @addFavorite.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى المفضلة'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFavorite;

  /// No description provided for @noImage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صورة'**
  String get noImage;

  /// No description provided for @loginRequired.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للمتابعة'**
  String get loginRequired;

  /// No description provided for @listingNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان غير موجود أو غير متاح.'**
  String get listingNotFound;

  /// No description provided for @waMessage.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، أنا مهتم بإعلانك في سوق تعز: {title}'**
  String waMessage(String title);

  /// No description provided for @reportReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب البلاغ'**
  String get reportReason;

  /// No description provided for @reportDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (اختياري)'**
  String get reportDetails;

  /// No description provided for @reportSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ. شكراً لك.'**
  String get reportSent;

  /// No description provided for @reasonSpam.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مزعج'**
  String get reasonSpam;

  /// No description provided for @reasonProhibited.
  ///
  /// In ar, this message translates to:
  /// **'محتوى محظور'**
  String get reasonProhibited;

  /// No description provided for @reasonFraud.
  ///
  /// In ar, this message translates to:
  /// **'احتيال'**
  String get reasonFraud;

  /// No description provided for @reasonOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get reasonOther;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط الاستعادة'**
  String get sendResetLink;

  /// No description provided for @resetSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط استعادة كلمة المرور إلى بريدك.'**
  String get resetSent;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب؟'**
  String get haveAccount;

  /// No description provided for @continueGoogle.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة عبر Google'**
  String get continueGoogle;

  /// No description provided for @verifyEmailBanner.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد بريدك الإلكتروني. تم إرسال رسالة التفعيل.'**
  String get verifyEmailBanner;

  /// No description provided for @resendVerification.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال رسالة التفعيل'**
  String get resendVerification;

  /// No description provided for @verificationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالة التفعيل.'**
  String get verificationSent;

  /// No description provided for @suspendedBanner.
  ///
  /// In ar, this message translates to:
  /// **'حسابك معلّق ولا يمكنك النشر أو المراسلة.'**
  String get suspendedBanner;

  /// No description provided for @accountRole.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية'**
  String get accountRole;

  /// No description provided for @createListing.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إعلان'**
  String get createListing;

  /// No description provided for @editListing.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإعلان'**
  String get editListing;

  /// No description provided for @listingTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإعلان'**
  String get listingTitle;

  /// No description provided for @priceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر (ريال يمني)'**
  String get priceLabel;

  /// No description provided for @priceType.
  ///
  /// In ar, this message translates to:
  /// **'نوع السعر'**
  String get priceType;

  /// No description provided for @contactPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم التواصل (واتساب)'**
  String get contactPhone;

  /// No description provided for @images.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get images;

  /// No description provided for @addImages.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صور'**
  String get addImages;

  /// No description provided for @imagesHint.
  ///
  /// In ar, this message translates to:
  /// **'الصورة الأولى هي الغلاف. اسحب لإعادة الترتيب. حتى 8 صور، 5 ميجابايت لكل صورة.'**
  String get imagesHint;

  /// No description provided for @setCover.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كغلاف'**
  String get setCover;

  /// No description provided for @removeImage.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get removeImage;

  /// No description provided for @coverBadge.
  ///
  /// In ar, this message translates to:
  /// **'الغلاف'**
  String get coverBadge;

  /// No description provided for @submitForReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمراجعة'**
  String get submitForReview;

  /// No description provided for @listingSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الإعلان للمراجعة.'**
  String get listingSubmitted;

  /// No description provided for @statusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get statusDraft;

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get statusPending;

  /// No description provided for @statusPublished.
  ///
  /// In ar, this message translates to:
  /// **'منشور'**
  String get statusPublished;

  /// No description provided for @statusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get statusRejected;

  /// No description provided for @statusPaused.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get statusPaused;

  /// No description provided for @statusSold.
  ///
  /// In ar, this message translates to:
  /// **'مباع'**
  String get statusSold;

  /// No description provided for @statusArchived.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get statusArchived;

  /// No description provided for @rejectionReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get rejectionReason;

  /// No description provided for @pause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'إعادة النشر'**
  String get resume;

  /// No description provided for @markSold.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمباع'**
  String get markSold;

  /// No description provided for @deleteListing.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإعلان'**
  String get deleteListing;

  /// No description provided for @deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا الإعلان؟ سيتم أرشفته.'**
  String get deleteConfirm;

  /// No description provided for @sellerDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة البائع'**
  String get sellerDashboard;

  /// No description provided for @totalListings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإعلانات'**
  String get totalListings;

  /// No description provided for @myListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلاناتي'**
  String get myListings;

  /// No description provided for @noListings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات بعد.'**
  String get noListings;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي إعلان إلى المفضلة.'**
  String get favoritesEmpty;

  /// No description provided for @messagesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get messagesTitle;

  /// No description provided for @messagesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محادثات.'**
  String get messagesEmpty;

  /// No description provided for @typeMessage.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @messageRead.
  ///
  /// In ar, this message translates to:
  /// **'تمت القراءة'**
  String get messageRead;

  /// No description provided for @messageSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسلت'**
  String get messageSent;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات.'**
  String get notificationsEmpty;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @ntfApproved.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة على إعلانك ونشره'**
  String get ntfApproved;

  /// No description provided for @ntfRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إعلانك'**
  String get ntfRejected;

  /// No description provided for @ntfNewMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك رسالة جديدة'**
  String get ntfNewMessage;

  /// No description provided for @ntfStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة إعلانك'**
  String get ntfStatus;

  /// No description provided for @ntfAccount.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة حسابك'**
  String get ntfAccount;

  /// No description provided for @reviewsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييمات البائع'**
  String get reviewsTitle;

  /// No description provided for @noReviews.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد.'**
  String get noReviews;

  /// No description provided for @writeReview.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تقييماً'**
  String get writeReview;

  /// No description provided for @reviewText.
  ///
  /// In ar, this message translates to:
  /// **'تعليقك (اختياري)'**
  String get reviewText;

  /// No description provided for @reviewSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال تقييمك وسيظهر بعد المراجعة.'**
  String get reviewSubmitted;

  /// No description provided for @adminTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الإدارة'**
  String get adminTitle;

  /// No description provided for @adminDashboard.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get adminDashboard;

  /// No description provided for @adminModeration.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الإعلانات'**
  String get adminModeration;

  /// No description provided for @adminUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get adminUsers;

  /// No description provided for @adminReports.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات'**
  String get adminReports;

  /// No description provided for @adminCategories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get adminCategories;

  /// No description provided for @adminLocations.
  ///
  /// In ar, this message translates to:
  /// **'المواقع'**
  String get adminLocations;

  /// No description provided for @adminLogs.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get adminLogs;

  /// No description provided for @statUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get statUsers;

  /// No description provided for @statPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get statPending;

  /// No description provided for @statPublished.
  ///
  /// In ar, this message translates to:
  /// **'منشورة'**
  String get statPublished;

  /// No description provided for @statRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get statRejected;

  /// No description provided for @statSold.
  ///
  /// In ar, this message translates to:
  /// **'مباعة'**
  String get statSold;

  /// No description provided for @statOpenReports.
  ///
  /// In ar, this message translates to:
  /// **'بلاغات مفتوحة'**
  String get statOpenReports;

  /// No description provided for @approve.
  ///
  /// In ar, this message translates to:
  /// **'موافقة'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @rejectReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get rejectReasonHint;

  /// No description provided for @suspend.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get suspend;

  /// No description provided for @unsuspend.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التعليق'**
  String get unsuspend;

  /// No description provided for @feature.
  ///
  /// In ar, this message translates to:
  /// **'تمييز'**
  String get feature;

  /// No description provided for @unfeature.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التمييز'**
  String get unfeature;

  /// No description provided for @dismissReport.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل البلاغ'**
  String get dismissReport;

  /// No description provided for @removeListing.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الإعلان'**
  String get removeListing;

  /// No description provided for @nameAr.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالعربية'**
  String get nameAr;

  /// No description provided for @nameEn.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالإنجليزية'**
  String get nameEn;

  /// No description provided for @roleBuyer.
  ///
  /// In ar, this message translates to:
  /// **'مشتري'**
  String get roleBuyer;

  /// No description provided for @roleSeller.
  ///
  /// In ar, this message translates to:
  /// **'بائع'**
  String get roleSeller;

  /// No description provided for @roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get roleAdmin;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير عام'**
  String get roleSuperAdmin;

  /// No description provided for @actionDone.
  ///
  /// In ar, this message translates to:
  /// **'تم التنفيذ'**
  String get actionDone;

  /// No description provided for @pageNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get pageNotFound;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get backToHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
