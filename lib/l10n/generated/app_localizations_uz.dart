// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Gelion';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navSearch => 'Qidiruv';

  @override
  String get navCart => 'Savat';

  @override
  String get navProfile => 'Profil';

  @override
  String get currencySom => 'so\'m';

  @override
  String get guestName => 'Mehmon';

  @override
  String get loginWelcomeSubtitle =>
      'Xush kelibsiz! Eng mazali taomlar sizni kutmoqda.';

  @override
  String get loginEmailLabel => 'Telefon yoki Email';

  @override
  String get loginPasswordLabel => 'Parol';

  @override
  String get loginEmailHint => 'namuna@mail.com';

  @override
  String get loginPasswordHint => '••••••';

  @override
  String get loginForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get loginButton => 'Kirish';

  @override
  String get loginDivider => 'YOKI DAVOM ETING';

  @override
  String get loginNoAccount => 'Hisobingiz yo‘qmi? ';

  @override
  String get loginRegisterLink => 'Ro\'yxatdan o\'tish';

  @override
  String get loginGoogleSoon => 'Google login keyinroq qo‘shiladi';

  @override
  String get loginAppleSoon => 'Apple login keyinroq qo‘shiladi';

  @override
  String get loginResetEnterEmail => 'Parol tiklash uchun avval email kiriting';

  @override
  String get loginResetSent => 'Tiklash havolasi emailingizga yuborildi';

  @override
  String get registerTitle => 'Ro\'yxatdan o\'tish';

  @override
  String get registerSubtitle =>
      'Ilovadan to‘liq foydalanish uchun hisob yarating';

  @override
  String get registerFullName => 'To\'liq ismingiz';

  @override
  String get registerPhone => 'Telefon raqamingiz';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Parol';

  @override
  String get registerButton => 'Ro\'yxatdan o\'tish';

  @override
  String get registerDivider => 'YOKI';

  @override
  String get registerHaveAccount => 'Hisobingiz bormi? ';

  @override
  String get registerLoginLink => 'Kirish';

  @override
  String get registerGoogleSoon =>
      'Google ro\'yxatdan o\'tish keyin qo\'shiladi';

  @override
  String get registerAppleSoon => 'Apple ro\'yxatdan o\'tish keyin qo\'shiladi';

  @override
  String get hintFullName => 'Ism va familiya';

  @override
  String get hintPhone => '+998';

  @override
  String get labelName => 'Ism';

  @override
  String get labelPhone => 'Telefon';

  @override
  String validationEnterField(String label) {
    return '$label kiriting';
  }

  @override
  String get validationEnterEmail => 'Email kiriting';

  @override
  String get validationEmailInvalid => 'Email noto‘g‘ri';

  @override
  String get validationEnterPassword => 'Parol kiriting';

  @override
  String get validationPasswordShort => 'Parol kamida 6 ta belgi bo‘lsin';

  @override
  String get validationEnterPhone => 'Telefon raqamini kiriting';

  @override
  String get validationPhoneInvalid => 'To‘g‘ri telefon raqamini kiriting';

  @override
  String get validationPasswordMismatch => 'Parollar mos kelmaydi';

  @override
  String get validationPasswordNeedUpper => 'Kamida bitta katta harf qo‘shing';

  @override
  String get validationPasswordNeedLower => 'Kamida bitta kichik harf qo‘shing';

  @override
  String get validationPasswordNeedDigit => 'Kamida bitta raqam qo‘shing';

  @override
  String get validationPasswordNeedSpecial =>
      'Kamida bitta maxsus belgi qo‘shing';

  @override
  String get firebaseErrorInvalidEmail => 'Email format noto‘g‘ri.';

  @override
  String get firebaseErrorUserNotFound => 'Foydalanuvchi topilmadi.';

  @override
  String get firebaseErrorWrongCredential => 'Email yoki parol noto‘g‘ri.';

  @override
  String get firebaseErrorEmailInUse =>
      'Bu email allaqachon ro‘yxatdan o‘tgan.';

  @override
  String get firebaseErrorWeakPassword => 'Parol juda kuchsiz.';

  @override
  String get firebaseErrorNetwork => 'Internet aloqasini tekshiring.';

  @override
  String get firebaseErrorAuthGeneric =>
      'Autentifikatsiyada xatolik yuz berdi.';

  @override
  String get firebaseErrorRequiresRecentLogin =>
      'Avval tizimdan chiqib, qayta kiring, so‘ng qayta urinib ko‘ring.';

  @override
  String get firebaseErrorTooManyRequests =>
      'Juda ko‘p urinish. Keyinroq qayta urinib ko‘ring.';

  @override
  String get firebaseErrorUnavailable => 'Firebase serveriga ulanib bo‘lmadi.';

  @override
  String get firebaseErrorGeneric => 'Firebase xatoligi yuz berdi.';

  @override
  String get firebaseErrorUnknown => 'Noma’lum xatolik yuz berdi.';

  @override
  String firebaseConnectionError(String message) {
    return 'Firebase ulanishida xatolik.\n$message';
  }

  @override
  String get retry => 'Qayta urinish';

  @override
  String firebaseInitError(String error) {
    return 'Firebase initialize xatosi: $error';
  }

  @override
  String get firebaseConfigIncomplete =>
      'Firebase config to‘liq emas (apiKey/appId bo‘sh).';

  @override
  String get splashTagline => 'Pitsa va Muzqaymoq';

  @override
  String get splashLoading => 'YUKLANMOQDA...';

  @override
  String get onboardingSkip => 'O\'tkazib yuborish';

  @override
  String get onboardingNext => 'Keyingi';

  @override
  String get onboardingStart => 'Boshlash';

  @override
  String onboardingProgress(int page) {
    return 'ONBOARDING $page';
  }

  @override
  String get onboarding1Title => 'Issiq va yangi\npizza';

  @override
  String get onboarding1Body =>
      'Bizning olovda pishirilgan pitsalarimiz to\'g\'ridan-to\'g\'ri eshigingizga issiq holda yetkaziladi.';

  @override
  String get onboarding2Title => 'Sovuq va mazali\nmuzqaymoq';

  @override
  String get onboarding2Body =>
      'Har bir qoshiqda quyoshli kunning zavqi va kremning mayinligini his eting.';

  @override
  String get onboarding3Title => 'Tez yetkazib berish';

  @override
  String get onboarding3Body =>
      'Sevimli taomlaringiz issiq va yangi holatda darhol eshigingiz tagida bo‘ladi.';

  @override
  String get homeGreeting => 'Assalomu alaykum 👋';

  @override
  String get homeSearchHint => 'Pizza yoki muzqaymoq qidiring...';

  @override
  String get homeSectionPopular => 'Mashhur taomlar';

  @override
  String homeSectionAssortment(String category) {
    return '$category — assortiment';
  }

  @override
  String homeProductCount(int count) {
    return '$count ta mahsulot';
  }

  @override
  String get homeFullList => 'To‘liq ro‘yxat';

  @override
  String get homeSearchEmpty =>
      'Bu kategoriyada yoki qidiruvda natija yo‘q. Boshqa kategoriyani tanlang.';

  @override
  String get homeFoodsEmpty =>
      'Hozircha taomlar yo‘q. Yangi taomlar avtomatik paydo bo‘ladi.';

  @override
  String get homeFoodsLoadError =>
      'Taomlarni yuklab bo‘lmadi. Internetni tekshirib qayta urinib ko‘ring.';

  @override
  String get homeCategoriesEmpty => 'Kategoriyalar hali yo‘q';

  @override
  String get homeSupportSoon => 'Qo‘llab-quvvatlash — tez orada';

  @override
  String get homeNotificationsSoon => 'Bildirishnomalar — tez orada';

  @override
  String get homeCategoriesTitle => 'Kategoriyalar';

  @override
  String get homeCategoryTooltip => 'Kategoriya sahifasi';

  @override
  String get homeCategoryAll => 'Hammasi';

  @override
  String get homeAllFoodsTitle => 'Barcha taomlar';

  @override
  String categoryAssortmentTitle(String category) {
    return '$category assortiment';
  }

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryIcecream => 'Muzqaymoq';

  @override
  String get categoryBurger => 'Burger';

  @override
  String get categoryHotDog => 'Hod-dog';

  @override
  String get categoryLavash => 'Lavash';

  @override
  String get categorySandwich => 'Sendvich';

  @override
  String get categoryButterbrod => 'Buterbrod';

  @override
  String get categorySalads => 'Salatlar';

  @override
  String get categoryDrinks => 'Ichimliklar';

  @override
  String get categorySearchHint => 'Bu kategoriyada qidirish...';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortCheap => 'Arzon';

  @override
  String get sortNew => 'Yangi';

  @override
  String categoryItemCount(int count) {
    return '$count ta';
  }

  @override
  String get categoryEmptyTitle => 'Bu kategoriyada hozircha mahsulot yo‘q';

  @override
  String get categoryEmptySubtitle =>
      'Qidiruvni o‘zgartirib ko‘ring yoki boshqa kategoriyani tanlang.';

  @override
  String get productIngredients => 'Tarkibi';

  @override
  String get productQuantity => 'Miqdor';

  @override
  String get productRecommendations => 'Tavsiya etamiz';

  @override
  String get productDefaultIngredients => 'Premium ingredientlar';

  @override
  String productAddToCart(String amount, String currency) {
    return 'Savatga — $amount $currency';
  }

  @override
  String productAddedSnack(String name, int qty) {
    return '$name × $qty savatga qo‘shildi';
  }

  @override
  String get cartTitleBar => 'Gelion';

  @override
  String get cartPromoLabel => 'Promo-kod';

  @override
  String get cartAddressLabel => 'Yetkazib berish manzili';

  @override
  String get cartAddressHint => 'Ko‘cha, uy, kirish, qavat…';

  @override
  String get cartAddressRequired => 'Yetkazib berish manzilini kiriting';

  @override
  String get cartPromoHint => 'Promo-kod';

  @override
  String get cartPromoApply => 'Qo‘llash';

  @override
  String get cartSummaryTitle => 'Xulosa';

  @override
  String get cartRowProducts => 'Mahsulotlar';

  @override
  String get cartRowDelivery => 'Yetkazib berish';

  @override
  String get cartRowDiscount => 'Chegirma';

  @override
  String get cartRowTotal => 'Jami';

  @override
  String get cartCheckout => 'Buyurtma berish';

  @override
  String get cartEmptyTitle => 'Savat hozircha bo‘sh';

  @override
  String get cartEmptySubtitle =>
      'Masalan: Eritilgan Monster Burger yoki Choco Melt Sheyk — bosh sahifadan qo‘shing.';

  @override
  String get cartBrowseFoods => 'Taomlarni ko‘rish';

  @override
  String get cartPromoEnter => 'Promo-kodni kiriting';

  @override
  String get cartPromo10 => '10% chegirma qo‘llandi';

  @override
  String get cartPromo5000 => '5 000 so‘m chegirma qo‘llandi';

  @override
  String get cartPromo15 => '15% chegirma qo‘llandi';

  @override
  String get cartPromoNotFound => 'Promo-kod topilmadi';

  @override
  String cartOrderAccepted(String orderNo, String total) {
    return 'Buyurtma qabul qilindi ($orderNo) — $total';
  }

  @override
  String get cartOrderSuccessTitle => 'Buyurtma qabul qilindi!';

  @override
  String cartOrderSuccessMessage(String orderNo, String total) {
    return 'Buyurtma raqami: $orderNo\nJami: $total';
  }

  @override
  String get cartOrderSuccessOk => 'Yaxshi';

  @override
  String get cartOrderFailed =>
      'Buyurtma yuborilmadi. Internet yoki akkauntni tekshiring.';

  @override
  String cartAddedSimple(String name) {
    return '$name savatga qo‘shildi';
  }

  @override
  String get profilePhotoTitle => 'Profil rasmi';

  @override
  String get profilePhotoCropDone => 'Kesish';

  @override
  String get profilePhotoCamera => 'Kamera';

  @override
  String get profilePhotoCameraHint => 'Yangi rasm oling';

  @override
  String get profilePhotoGallery => 'Galereya';

  @override
  String get profilePhotoGalleryHint => 'Telefoningizdan tanlang';

  @override
  String get profilePhotoFiles => 'Fayllar';

  @override
  String get profilePhotoFilesHint => 'Qurilmadan fayl tanlang';

  @override
  String get profilePhotoPermissionDenied =>
      'Ruxsat berilmadi. Sozlamalardan yoqing.';

  @override
  String get profilePhotoDefault => 'Standart avatar';

  @override
  String get profilePhotoUpdated => 'Profil rasmi yangilandi';

  @override
  String get profilePhotoUploading => 'Rasm yuklanmoqda…';

  @override
  String get profilePhotoUploadFailed => 'Rasm yuklanmadi';

  @override
  String get profilePhotoRemove => 'Rasmni o‘chirish';

  @override
  String get profilePhotoUploadSuccess => 'Rasm muvaffaqiyatli yuklandi';

  @override
  String get profileLogoutTitle => 'Chiqishni tasdiqlang';

  @override
  String get profileLogoutMessage =>
      'Haqiqatan ham akkauntdan chiqmoqchimisiz?';

  @override
  String get profileCancel => 'Bekor qilish';

  @override
  String get profileLogout => 'Chiqish';

  @override
  String get profileCartHintSnack =>
      'Savatga o‘tish pastki panel orqali amalga oshadi';

  @override
  String get profileEditPhoto => 'Rasmni tahrirlash';

  @override
  String get profileAvatarPickTitle => 'Avatar tanlang';

  @override
  String get profileAvatarPickSubtitle =>
      'Avval kategoriyani tanlang, keyin rasmni bosing';

  @override
  String get profileAvatarPickBack => 'Orqaga';

  @override
  String get profileAvatarPickEmpty => 'Bu kategoriyada avatarlar topilmadi';

  @override
  String get profileGoldMember => '⭐ Oltin a’zo';

  @override
  String get profileOrdersTitle => 'Buyurtmalar tarixi';

  @override
  String get profileOrdersSubtitle => 'Oldingi buyurtmalarni ko‘rish';

  @override
  String get profileSettingsTitle => 'Sozlamalar';

  @override
  String get profileSettingsSubtitle => 'Ilova sozlamalari va xavfsizlik';

  @override
  String get profileLanguageTitle => 'Til tanlash';

  @override
  String get profileSignOut => 'Chiqish';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get settingsTheme => 'Mavzu';

  @override
  String get settingsThemeLight => 'Kunduz';

  @override
  String get settingsThemeDark => 'Tun';

  @override
  String get settingsSectionPersonal => 'Shaxsiy ma’lumotlar';

  @override
  String get settingsSectionSecurity => 'Xavfsizlik';

  @override
  String get settingsSectionAbout => 'Ilova haqida';

  @override
  String get settingsFullName => 'Ism familiya';

  @override
  String get settingsPhone => 'Telefon';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsSave => 'Saqlash';

  @override
  String get settingsSaving => 'Saqlanmoqda…';

  @override
  String get settingsSaved => 'Profil yangilandi';

  @override
  String get settingsSaveError =>
      'Saqlab bo‘lmadi. Internetni tekshirib qayta urinib ko‘ring.';

  @override
  String get settingsVerifyEmailSent =>
      'Yangi email manziliga tasdiqlash havolasi yuborildi.';

  @override
  String get settingsPasswordChange => 'Parolni o‘zgartirish';

  @override
  String get settingsPasswordChangeSubtitle => 'Joriy parol talab qilinadi';

  @override
  String get settingsPrivacy => 'Maxfiylik siyosati';

  @override
  String get settingsPrivacySubtitle =>
      'Ma’lumotlaringizdan qanday foydalanamiz';

  @override
  String get settingsTerms => 'Foydalanish shartlari';

  @override
  String get settingsTermsSubtitle => 'Ilovadan foydalanish qoidalari';

  @override
  String get settingsCouldNotOpenLink => 'Havolani ochib bo‘lmadi';

  @override
  String get changePasswordTitle => 'Parolni o‘zgartirish';

  @override
  String get changePasswordCurrent => 'Joriy parol';

  @override
  String get changePasswordNew => 'Yangi parol';

  @override
  String get changePasswordConfirm => 'Yangi parolni tasdiqlang';

  @override
  String get changePasswordSubmit => 'Parolni yangilash';

  @override
  String get changePasswordSuccessTitle => 'Parol yangilandi';

  @override
  String get changePasswordSuccessBody =>
      'Parolingiz muvaffaqiyatli o‘zgartirildi.';

  @override
  String get changePasswordDone => 'Yaxshi';

  @override
  String get settingsSectionFeedback => 'Sharh va fikr';

  @override
  String get feedbackSendTitle => 'Sharh yuborish';

  @override
  String get feedbackSendSubtitle => 'Baholang va fikringizni yozing';

  @override
  String get feedbackPageTitle => 'Sharh va fikr';

  @override
  String get feedbackYourRating => 'Bahoyingiz';

  @override
  String get feedbackMessageLabel => 'Sharhingiz';

  @override
  String get feedbackMessageHint =>
      'Nima yoqdi yoki nima yaxshilanishi kerak? (kamida 10 belgi)';

  @override
  String get feedbackSubmit => 'Yuborish';

  @override
  String get feedbackSuccessTitle => 'Rahmat!';

  @override
  String get feedbackSuccessBody => 'Fikr-mulohazangiz qabul qilindi.';

  @override
  String get feedbackSuccessOk => 'Yaxshi';

  @override
  String get feedbackValidationEmpty => 'Matnni kiriting';

  @override
  String get feedbackValidationMin10 => 'Kamida 10 ta belgi bo‘lsin';

  @override
  String get adminFeedbackTitle => 'Sharhlar';

  @override
  String get adminFeedbackSubtitle => 'Barcha sharhlar (admin)';

  @override
  String get adminFeedbackEmpty => 'Hozircha sharh yo‘q';

  @override
  String get adminFeedbackDeleteTitle => 'Sharhni o‘chirish?';

  @override
  String get adminFeedbackDeleteBody => 'Bu amalni qaytarib bo‘lmaydi.';

  @override
  String get adminFeedbackDelete => 'O‘chirish';

  @override
  String get adminFeedbackMarkRead => 'O‘qilgan deb belgilash';

  @override
  String get adminFeedbackMarkUnread => 'O‘qilmagan qilish';

  @override
  String get adminFeedbackDeleted => 'Sharh o‘chirildi';

  @override
  String get adminFoodsTitle => 'Taomlar (admin)';

  @override
  String get adminFoodsSubtitle => 'Rasm va narxni boshqarish';

  @override
  String get adminFoodsEmpty => 'Hozircha taom yo‘q';

  @override
  String get adminFoodAdd => 'Taom qo‘shish';

  @override
  String get adminFoodEdit => 'Taomni tahrirlash';

  @override
  String get adminFoodSave => 'Saqlash';

  @override
  String get adminFoodCreate => 'Taom yaratish';

  @override
  String get adminFoodImageRequired => 'Taom rasmini tanlang';

  @override
  String get adminFoodSaved => 'Taom saqlandi';

  @override
  String get adminFoodName => 'Nomi';

  @override
  String get adminFoodPrice => 'Narxi (so‘m)';

  @override
  String get adminFoodStock => 'Zaxira';

  @override
  String get adminFoodDescription => 'Tavsif';

  @override
  String get adminFoodCategory => 'Kategoriya';

  @override
  String get adminFoodPopular => 'Mashhur';

  @override
  String get adminFoodActive => 'Faol (mobilda ko‘rinadi)';

  @override
  String get adminFoodDeleteTitle => 'Taomni o‘chirish?';

  @override
  String get adminFoodDeleteBody => 'Bu amalni qaytarib bo‘lmaydi.';

  @override
  String get adminFoodIngredients => 'Tarkibi (ingredientlar)';

  @override
  String get adminFoodRecommended => 'Tavsiya etiladi';

  @override
  String get adminCategoriesTitle => 'Kategoriyalar (admin)';

  @override
  String get adminCategoriesSubtitle => 'Menyu kategoriyalarini boshqarish';

  @override
  String get adminCategoriesEmpty => 'Hozircha kategoriya yo‘q';

  @override
  String get adminCategoryAdd => 'Kategoriya qo‘shish';

  @override
  String get adminCategoryEdit => 'Kategoriyani tahrirlash';

  @override
  String get adminCategoryName => 'Nomi';

  @override
  String get adminCategoryDescription => 'Tavsif';

  @override
  String get adminCategoryOrder => 'Tartib';

  @override
  String get adminCategoryIcon => 'Icon kaliti';

  @override
  String get adminCategorySaved => 'Kategoriya saqlandi';

  @override
  String get adminCategoryDeleteTitle => 'Kategoriyani o‘chirish?';

  @override
  String get adminCategoryDeleteBody => 'Bu amalni qaytarib bo‘lmaydi.';

  @override
  String get adminBannersTitle => 'Bannerlar (admin)';

  @override
  String get adminBannersSubtitle => 'Bosh sahifa reklamalari';

  @override
  String get adminBannersEmpty => 'Hozircha banner yo‘q';

  @override
  String get adminBannerAdd => 'Banner qo‘shish';

  @override
  String get adminBannerEdit => 'Bannerni tahrirlash';

  @override
  String get adminBannerChangeImage => 'Rasmni o‘zgartirish';

  @override
  String get adminBannerTitle => 'Sarlavha';

  @override
  String get adminBannerSubtitle => 'Pastki matn';

  @override
  String get adminBannerButton => 'Tugma matni';

  @override
  String get adminBannerLink => 'Havola (category:ID yoki product:ID)';

  @override
  String get adminBannerImageRequired => 'Banner rasmini tanlang';

  @override
  String get adminBannerSaved => 'Banner saqlandi';

  @override
  String get adminBannerDeleteTitle => 'Bannerni o‘chirish?';

  @override
  String get adminBannerDeleteBody => 'Bu amalni qaytarib bo‘lmaydi.';

  @override
  String get searchTabTitle => 'Qidiruv';

  @override
  String get searchTabHint => 'Mahsulot nomi bo‘yicha qidiring…';

  @override
  String get searchTabEmpty => 'Mahsulotlar hozircha yo‘q.';

  @override
  String get searchTabNoResults => 'Natija topilmadi.';

  @override
  String productStockLimit(String name) {
    return '$name uchun zaxira yetarli emas';
  }

  @override
  String productUnavailable(String name) {
    return '$name hozir mavjud emas';
  }

  @override
  String productOutOfStock(String name) {
    return '$name tugagan';
  }

  @override
  String get productOutOfStockLabel => 'Tugagan';

  @override
  String get adminFoodStockHint => 'Bo‘sh = cheksiz, 0 = tugagan';

  @override
  String get adminBannerDiscount => 'Chegirma matni';

  @override
  String get favoritesTitle => 'Sevimlilar';

  @override
  String get favoritesSubtitle => 'Saqlangan taomlar';

  @override
  String get favoritesEmpty => 'Hozircha sevimli taom yo‘q';

  @override
  String get retryLoad => 'Qayta yuklash';

  @override
  String get adminOrdersTitle => 'Buyurtmalar';

  @override
  String get adminOrdersSubtitle =>
      'Mijoz buyurtmalarini real vaqtda boshqaring';

  @override
  String get adminOrdersEmpty => 'Hozircha buyurtmalar yo‘q';

  @override
  String get adminOrdersLoadError => 'Buyurtmalarni yuklab bo‘lmadi';

  @override
  String get adminOrderCustomer => 'Mijoz';

  @override
  String get adminOrderPhone => 'Telefon';

  @override
  String get adminOrderDeliveryAddress => 'Yetkazib berish manzili';

  @override
  String get adminOrderItems => 'Buyurtma tarkibi';

  @override
  String get adminOrderStatusLabel => 'Buyurtma holati';

  @override
  String get adminOrderStatusUpdated => 'Holat yangilandi';

  @override
  String get adminOrderStatusFailed => 'Holatni yangilab bo‘lmadi';

  @override
  String get orderStatusPending => 'Kutilmoqda';

  @override
  String get orderStatusAccepted => 'Qabul qilindi';

  @override
  String get orderStatusPreparing => 'Tayyorlanmoqda';

  @override
  String get orderStatusDelivering => 'Yetkazilmoqda';

  @override
  String get orderStatusCompleted => 'Yetkazildi';

  @override
  String get orderStatusCancelled => 'Bekor qilindi';

  @override
  String get orderHistoryTitle => 'Buyurtmalar tarixi';

  @override
  String get orderHistoryEmpty => 'Hozircha buyurtmalar yo‘q';

  @override
  String get orderHistoryEmptyHint =>
      'Savatdan buyurtma berganingizdan keyin ular shu yerda ko‘rinadi';

  @override
  String get orderHistoryAuthRequired =>
      'Buyurtmalarni ko‘rish uchun tizimga kiring';

  @override
  String orderHistoryItemCount(int count) {
    return '$count ta mahsulot';
  }

  @override
  String orderHistoryTotal(String amount, String currency) {
    return 'Jami: $amount $currency';
  }

  @override
  String get orderDetailPlacedAt => 'Buyurtma vaqti';

  @override
  String get orderDetailTimeline => 'Buyurtma holati';

  @override
  String orderHistoryOrder(String id) {
    return 'Buyurtma #$id';
  }

  @override
  String orderHistoryLine(int count, int amount, String currency) {
    return '$count ta mahsulot • $amount $currency';
  }

  @override
  String get orderHistoryPlaceOrder => 'Buyurtma berish';

  @override
  String get orderHistorySearchHint => 'Buyurtma raqami (#CM...)';

  @override
  String get orderFilterAll => 'Barchasi';

  @override
  String get orderFilterToday => 'Bugun';

  @override
  String get orderFilterWeek => '7 kun';

  @override
  String get orderFilterMonth => '30 kun';

  @override
  String get orderHistoryOffline =>
      'Oflayn — saqlangan buyurtmalar ko‘rsatilmoqda';

  @override
  String get orderDetailPayment => 'To‘lov turi';

  @override
  String get orderPaymentCash => 'Naqd';

  @override
  String get orderPaymentCard => 'Karta';

  @override
  String get orderPaymentOnline => 'Onlayn';

  @override
  String get orderHistoryRetry => 'Qayta urinish';

  @override
  String get orderHistoryLoadFailed =>
      'Ma\'lumot yuklanmadi. Qayta urinib ko‘ring.';

  @override
  String get orderHistoryLoadMore => 'Ko‘proq yuklash';

  @override
  String get promoSlide1Badge => 'CHEKLANGAN TAKLIF';

  @override
  String get promoSlide1Title => 'Aksiya: 50% chegirma';

  @override
  String get promoSlide1Subtitle => 'Barcha pizzalarga';

  @override
  String get promoSlide2Badge => 'TEZ YETKAZISH';

  @override
  String get promoSlide2Title => '20 daqiqada yetkazamiz';

  @override
  String get promoSlide2Subtitle => 'Issiq va yangi taomlar';

  @override
  String get promoSlide3Badge => 'TOP MENYU';

  @override
  String get promoSlide3Title => 'Burger + ichimlik combo';

  @override
  String get promoSlide3Subtitle => 'Bugun maxsus narxda';

  @override
  String get productDescBurger =>
      'Go\'sht kotleti, aysberg, maxsus sous — issiqda';

  @override
  String get productDescPizza =>
      'Mozzarella, tomat sous, ziravorlar — pichoqda';

  @override
  String get productDescIcecream => 'Mazali muzqaymoq — sovuq va shirin';

  @override
  String get productDescHotDog => 'Issiq sousis, yumshoq non';

  @override
  String get productDescLavash =>
      'Lavash, go\'sht va sabzavot bilan to\'ldirilgan';

  @override
  String get productDescSandwich => 'Toster non, sous va tovuq';

  @override
  String get productDescButterbrod => 'Bodring noni va kalbasa';

  @override
  String get productDescSalads => 'Yangi sabzavotlar va sous';

  @override
  String get productDescDrinks => 'Salqin ichimlik';

  @override
  String get productDescDessert => 'Shirin desert';

  @override
  String get productDescDrinksAlt => 'Salqin va tetiklatuvchi';

  @override
  String get productDescDefault => 'Premium ingredientlar — yangi tayyorlangan';
}
