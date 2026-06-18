// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gelion';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Profile';

  @override
  String get currencySom => 'UZS';

  @override
  String get guestName => 'Guest';

  @override
  String get loginWelcomeSubtitle =>
      'Welcome! The tastiest food is waiting for you.';

  @override
  String get loginEmailLabel => 'Phone or Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginEmailHint => 'sample@mail.com';

  @override
  String get loginPasswordHint => '••••••';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginDivider => 'OR CONTINUE WITH';

  @override
  String get loginNoAccount => 'No account? ';

  @override
  String get loginRegisterLink => 'Sign up';

  @override
  String get loginGoogleSoon => 'Google sign-in coming soon';

  @override
  String get loginAppleSoon => 'Apple sign-in coming soon';

  @override
  String get loginResetEnterEmail => 'Enter your email first to reset password';

  @override
  String get loginResetSent => 'Reset link sent to your email';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerSubtitle => 'Create an account to use the app fully';

  @override
  String get registerFullName => 'Full name';

  @override
  String get registerPhone => 'Phone number';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerButton => 'Sign up';

  @override
  String get registerDivider => 'OR';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLoginLink => 'Sign in';

  @override
  String get registerGoogleSoon => 'Google sign-up coming soon';

  @override
  String get registerAppleSoon => 'Apple sign-up coming soon';

  @override
  String get hintFullName => 'First and last name';

  @override
  String get hintPhone => '+998';

  @override
  String get labelName => 'Name';

  @override
  String get labelPhone => 'Phone';

  @override
  String validationEnterField(String label) {
    return 'Please enter $label';
  }

  @override
  String get validationEnterEmail => 'Please enter email';

  @override
  String get validationEmailInvalid => 'Invalid email';

  @override
  String get validationEnterPassword => 'Please enter password';

  @override
  String get validationPasswordShort =>
      'Password must be at least 6 characters';

  @override
  String get validationEnterPhone => 'Enter phone number';

  @override
  String get validationPhoneInvalid => 'Enter a valid phone number';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get validationPasswordNeedUpper => 'Add at least one uppercase letter';

  @override
  String get validationPasswordNeedLower => 'Add at least one lowercase letter';

  @override
  String get validationPasswordNeedDigit => 'Add at least one digit';

  @override
  String get validationPasswordNeedSpecial =>
      'Add at least one special character';

  @override
  String get firebaseErrorInvalidEmail => 'Invalid email format.';

  @override
  String get firebaseErrorUserNotFound => 'User not found.';

  @override
  String get firebaseErrorWrongCredential => 'Incorrect email or password.';

  @override
  String get firebaseErrorEmailInUse => 'This email is already registered.';

  @override
  String get firebaseErrorWeakPassword => 'Password is too weak.';

  @override
  String get firebaseErrorNetwork => 'Check your internet connection.';

  @override
  String get firebaseErrorAuthGeneric => 'Authentication error.';

  @override
  String get firebaseErrorRequiresRecentLogin =>
      'Please sign out and sign in again, then try once more.';

  @override
  String get firebaseErrorTooManyRequests =>
      'Too many attempts. Try again later.';

  @override
  String get firebaseErrorUnavailable => 'Could not reach Firebase server.';

  @override
  String get firebaseErrorGeneric => 'Firebase error occurred.';

  @override
  String get firebaseErrorUnknown => 'Unknown error occurred.';

  @override
  String firebaseConnectionError(String message) {
    return 'Firebase connection error.\n$message';
  }

  @override
  String get retry => 'Retry';

  @override
  String firebaseInitError(String error) {
    return 'Firebase initialization error: $error';
  }

  @override
  String get firebaseConfigIncomplete =>
      'Firebase config incomplete (apiKey/appId empty).';

  @override
  String get splashTagline => 'Pizza & Ice Cream';

  @override
  String get splashLoading => 'LOADING...';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String onboardingProgress(int page) {
    return 'ONBOARDING $page';
  }

  @override
  String get onboarding1Title => 'Hot and fresh\npizza';

  @override
  String get onboarding1Body =>
      'Our wood-fired pizzas go straight to your door piping hot.';

  @override
  String get onboarding2Title => 'Cold and creamy\nice cream';

  @override
  String get onboarding2Body =>
      'Feel the sunshine and silky cream in every spoonful.';

  @override
  String get onboarding3Title => 'Fast delivery';

  @override
  String get onboarding3Body =>
      'Your favorites arrive hot and fresh right at your doorstep.';

  @override
  String get homeGreeting => 'Hello 👋';

  @override
  String get homeSearchHint => 'Search pizza or ice cream...';

  @override
  String get homeSectionPopular => 'Popular dishes';

  @override
  String homeSectionAssortment(String category) {
    return '$category — assortment';
  }

  @override
  String homeProductCount(int count) {
    return '$count products';
  }

  @override
  String get homeFullList => 'Full list';

  @override
  String get homeSearchEmpty =>
      'No results in this category or search. Try another category.';

  @override
  String get homeFoodsEmpty =>
      'No dishes yet. Check back soon — new items appear automatically.';

  @override
  String get homeFoodsLoadError =>
      'Could not load dishes. Check your connection and try again.';

  @override
  String get homeCategoriesEmpty => 'No categories yet';

  @override
  String get homeSupportSoon => 'Support — coming soon';

  @override
  String get homeNotificationsSoon => 'Notifications — coming soon';

  @override
  String get homeCategoriesTitle => 'Categories';

  @override
  String get homeCategoryTooltip => 'Category page';

  @override
  String get homeCategoryAll => 'All';

  @override
  String get homeAllFoodsTitle => 'All dishes';

  @override
  String categoryAssortmentTitle(String category) {
    return '$category assortment';
  }

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryIcecream => 'Ice cream';

  @override
  String get categoryBurger => 'Burger';

  @override
  String get categoryHotDog => 'Hot dog';

  @override
  String get categoryLavash => 'Lavash';

  @override
  String get categorySandwich => 'Sandwich';

  @override
  String get categoryButterbrod => 'Open sandwich';

  @override
  String get categorySalads => 'Salads';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get categorySearchHint => 'Search in this category...';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortCheap => 'Cheap';

  @override
  String get sortNew => 'New';

  @override
  String categoryItemCount(int count) {
    return '$count pcs';
  }

  @override
  String get categoryEmptyTitle => 'No products in this category yet';

  @override
  String get categoryEmptySubtitle =>
      'Try changing the search or pick another category.';

  @override
  String get productIngredients => 'Ingredients';

  @override
  String get productQuantity => 'Quantity';

  @override
  String get productRecommendations => 'Recommended';

  @override
  String get productDefaultIngredients => 'Premium ingredients';

  @override
  String productAddToCart(String amount, String currency) {
    return 'Add to cart — $amount $currency';
  }

  @override
  String productAddedSnack(String name, int qty) {
    return '$name × $qty added to cart';
  }

  @override
  String get cartTitleBar => 'Gelion';

  @override
  String get cartPromoLabel => 'Promo code';

  @override
  String get cartAddressLabel => 'Delivery address';

  @override
  String get cartAddressHint => 'Street, house, entrance, floor…';

  @override
  String get cartAddressRequired => 'Enter delivery address';

  @override
  String get cartPromoHint => 'Promo code';

  @override
  String get cartPromoApply => 'Apply';

  @override
  String get cartSummaryTitle => 'Summary';

  @override
  String get cartRowProducts => 'Items';

  @override
  String get cartRowDelivery => 'Delivery';

  @override
  String get cartRowDiscount => 'Discount';

  @override
  String get cartRowTotal => 'Total';

  @override
  String get cartCheckout => 'Place order';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptySubtitle =>
      'Try Melted Monster Burger or Choco Melt Shake — add from home.';

  @override
  String get cartBrowseFoods => 'Browse dishes';

  @override
  String get cartPromoEnter => 'Enter a promo code';

  @override
  String get cartPromo10 => '10% discount applied';

  @override
  String get cartPromo5000 => '5,000 UZS discount applied';

  @override
  String get cartPromo15 => '15% discount applied';

  @override
  String get cartPromoNotFound => 'Promo code not found';

  @override
  String cartOrderAccepted(String orderNo, String total) {
    return 'Order accepted ($orderNo) — $total';
  }

  @override
  String get cartOrderSuccessTitle => 'Order placed!';

  @override
  String cartOrderSuccessMessage(String orderNo, String total) {
    return 'Order number: $orderNo\nTotal: $total';
  }

  @override
  String get cartOrderSuccessOk => 'OK';

  @override
  String get cartOrderFailed => 'Order failed. Check internet or your account.';

  @override
  String cartAddedSimple(String name) {
    return '$name added to cart';
  }

  @override
  String get profilePhotoTitle => 'Profile photo';

  @override
  String get profilePhotoCropDone => 'Crop';

  @override
  String get profilePhotoCamera => 'Camera';

  @override
  String get profilePhotoCameraHint => 'Take a new photo';

  @override
  String get profilePhotoGallery => 'Gallery';

  @override
  String get profilePhotoGalleryHint => 'Pick from your device';

  @override
  String get profilePhotoFiles => 'Files';

  @override
  String get profilePhotoFilesHint => 'Choose a file from your device';

  @override
  String get profilePhotoPermissionDenied =>
      'Permission denied. Enable it in Settings.';

  @override
  String get profilePhotoDefault => 'Default avatar';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String get profilePhotoUploading => 'Uploading photo…';

  @override
  String get profilePhotoUploadFailed => 'Could not upload photo';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get profilePhotoUploadSuccess => 'Photo uploaded successfully';

  @override
  String get profileLogoutTitle => 'Confirm sign out';

  @override
  String get profileLogoutMessage => 'Are you sure you want to sign out?';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileCartHintSnack => 'Open cart from the bottom bar';

  @override
  String get profileEditPhoto => 'Edit photo';

  @override
  String get profileAvatarPickTitle => 'Choose avatar';

  @override
  String get profileAvatarPickSubtitle => 'Pick a category, then tap an image';

  @override
  String get profileAvatarPickBack => 'Back';

  @override
  String get profileAvatarPickEmpty => 'No avatars in this category';

  @override
  String get profileGoldMember => '⭐ Gold member';

  @override
  String get profileOrdersTitle => 'Order history';

  @override
  String get profileOrdersSubtitle => 'View past orders';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileSettingsSubtitle => 'App settings and security';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionPersonal => 'Personal details';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsFullName => 'Full name';

  @override
  String get settingsPhone => 'Phone';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsSave => 'Save changes';

  @override
  String get settingsSaving => 'Saving…';

  @override
  String get settingsSaved => 'Profile updated';

  @override
  String get settingsSaveError =>
      'Could not save. Check connection and try again.';

  @override
  String get settingsVerifyEmailSent =>
      'Confirm your new email from the inbox link.';

  @override
  String get settingsPasswordChange => 'Change password';

  @override
  String get settingsPasswordChangeSubtitle => 'Current password required';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsPrivacySubtitle => 'How we use your data';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsTermsSubtitle => 'Rules for using the app';

  @override
  String get settingsCouldNotOpenLink => 'Could not open the link';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordNew => 'New password';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordSubmit => 'Update password';

  @override
  String get changePasswordSuccessTitle => 'Password updated';

  @override
  String get changePasswordSuccessBody =>
      'Your password was changed successfully.';

  @override
  String get changePasswordDone => 'OK';

  @override
  String get settingsSectionFeedback => 'Feedback';

  @override
  String get feedbackSendTitle => 'Send feedback';

  @override
  String get feedbackSendSubtitle => 'Rate us and share your thoughts';

  @override
  String get feedbackPageTitle => 'Feedback';

  @override
  String get feedbackYourRating => 'Your rating';

  @override
  String get feedbackMessageLabel => 'Your comment';

  @override
  String get feedbackMessageHint =>
      'What went well or what can we improve? (min. 10 characters)';

  @override
  String get feedbackSubmit => 'Send';

  @override
  String get feedbackSuccessTitle => 'Thank you!';

  @override
  String get feedbackSuccessBody => 'Your feedback has been received.';

  @override
  String get feedbackSuccessOk => 'OK';

  @override
  String get feedbackValidationEmpty => 'Please enter your comment';

  @override
  String get feedbackValidationMin10 => 'At least 10 characters';

  @override
  String get adminFeedbackTitle => 'Reviews';

  @override
  String get adminFeedbackSubtitle => 'All feedback (admin)';

  @override
  String get adminFeedbackEmpty => 'No feedback yet';

  @override
  String get adminFeedbackDeleteTitle => 'Delete this feedback?';

  @override
  String get adminFeedbackDeleteBody => 'This action cannot be undone.';

  @override
  String get adminFeedbackDelete => 'Delete';

  @override
  String get adminFeedbackMarkRead => 'Mark as read';

  @override
  String get adminFeedbackMarkUnread => 'Mark as unread';

  @override
  String get adminFeedbackDeleted => 'Feedback deleted';

  @override
  String get adminFoodsTitle => 'Foods (admin)';

  @override
  String get adminFoodsSubtitle => 'Manage images and prices';

  @override
  String get adminFoodsEmpty => 'No foods yet';

  @override
  String get adminFoodAdd => 'Add food';

  @override
  String get adminFoodEdit => 'Edit food';

  @override
  String get adminFoodSave => 'Save';

  @override
  String get adminFoodCreate => 'Create product';

  @override
  String get adminFoodImageRequired => 'Please select a food image';

  @override
  String get adminFoodSaved => 'Food saved';

  @override
  String get adminFoodName => 'Name';

  @override
  String get adminFoodPrice => 'Price';

  @override
  String get adminFoodStock => 'Stock';

  @override
  String get adminFoodDescription => 'Description';

  @override
  String get adminFoodCategory => 'Category';

  @override
  String get adminFoodPopular => 'Popular';

  @override
  String get adminFoodActive => 'Active (visible in app)';

  @override
  String get adminFoodDeleteTitle => 'Delete this food?';

  @override
  String get adminFoodDeleteBody => 'This cannot be undone.';

  @override
  String get adminFoodIngredients => 'Ingredients';

  @override
  String get adminFoodRecommended => 'Recommended';

  @override
  String get adminCategoriesTitle => 'Categories (admin)';

  @override
  String get adminCategoriesSubtitle => 'Manage menu categories';

  @override
  String get adminCategoriesEmpty => 'No categories yet';

  @override
  String get adminCategoryAdd => 'Add category';

  @override
  String get adminCategoryEdit => 'Edit category';

  @override
  String get adminCategoryName => 'Name';

  @override
  String get adminCategoryDescription => 'Description';

  @override
  String get adminCategoryOrder => 'Order';

  @override
  String get adminCategoryIcon => 'Icon key';

  @override
  String get adminCategorySaved => 'Category saved';

  @override
  String get adminCategoryDeleteTitle => 'Delete this category?';

  @override
  String get adminCategoryDeleteBody => 'This cannot be undone.';

  @override
  String get adminBannersTitle => 'Banners (admin)';

  @override
  String get adminBannersSubtitle => 'Home page promos';

  @override
  String get adminBannersEmpty => 'No banners yet';

  @override
  String get adminBannerAdd => 'Add banner';

  @override
  String get adminBannerEdit => 'Edit banner';

  @override
  String get adminBannerChangeImage => 'Change image';

  @override
  String get adminBannerTitle => 'Title';

  @override
  String get adminBannerSubtitle => 'Subtitle';

  @override
  String get adminBannerButton => 'Button text';

  @override
  String get adminBannerLink => 'Link (category:ID or product:ID)';

  @override
  String get adminBannerImageRequired => 'Please select a banner image';

  @override
  String get adminBannerSaved => 'Banner saved';

  @override
  String get adminBannerDeleteTitle => 'Delete this banner?';

  @override
  String get adminBannerDeleteBody => 'This cannot be undone.';

  @override
  String get searchTabTitle => 'Search';

  @override
  String get searchTabHint => 'Search by product name…';

  @override
  String get searchTabEmpty => 'No products yet.';

  @override
  String get searchTabNoResults => 'No results found.';

  @override
  String productStockLimit(String name) {
    return 'Not enough stock for $name';
  }

  @override
  String productUnavailable(String name) {
    return '$name is not available';
  }

  @override
  String productOutOfStock(String name) {
    return '$name is out of stock';
  }

  @override
  String get productOutOfStockLabel => 'Out of stock';

  @override
  String get adminFoodStockHint => 'Empty = unlimited, 0 = sold out';

  @override
  String get adminBannerDiscount => 'Discount label';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesSubtitle => 'Saved dishes';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get retryLoad => 'Retry';

  @override
  String get adminOrdersTitle => 'Orders';

  @override
  String get adminOrdersSubtitle => 'Manage customer orders in real time';

  @override
  String get adminOrdersEmpty => 'No orders yet';

  @override
  String get adminOrdersLoadError => 'Could not load orders';

  @override
  String get adminOrderCustomer => 'Customer';

  @override
  String get adminOrderPhone => 'Phone';

  @override
  String get adminOrderDeliveryAddress => 'Delivery address';

  @override
  String get adminOrderItems => 'Order items';

  @override
  String get adminOrderStatusLabel => 'Order status';

  @override
  String get adminOrderStatusUpdated => 'Status updated';

  @override
  String get adminOrderStatusFailed => 'Could not update status';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusAccepted => 'Accepted';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusDelivering => 'Delivering';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderHistoryTitle => 'Order history';

  @override
  String get orderHistoryEmpty => 'You have no orders yet';

  @override
  String get orderHistoryEmptyHint =>
      'Your orders will appear here after checkout';

  @override
  String get orderHistoryAuthRequired => 'Sign in to view your orders';

  @override
  String orderHistoryItemCount(int count) {
    return '$count items';
  }

  @override
  String orderHistoryTotal(String amount, String currency) {
    return 'Total: $amount $currency';
  }

  @override
  String get orderDetailPlacedAt => 'Order time';

  @override
  String get orderDetailTimeline => 'Order status';

  @override
  String orderHistoryOrder(String id) {
    return 'Order #$id';
  }

  @override
  String orderHistoryLine(int count, int amount, String currency) {
    return '$count items · $amount $currency';
  }

  @override
  String get orderHistoryPlaceOrder => 'Place order';

  @override
  String get orderHistorySearchHint => 'Order number (#CM...)';

  @override
  String get orderFilterAll => 'All';

  @override
  String get orderFilterToday => 'Today';

  @override
  String get orderFilterWeek => '7 days';

  @override
  String get orderFilterMonth => '30 days';

  @override
  String get orderHistoryOffline => 'Offline — showing saved orders';

  @override
  String get orderDetailPayment => 'Payment method';

  @override
  String get orderPaymentCash => 'Cash';

  @override
  String get orderPaymentCard => 'Card';

  @override
  String get orderPaymentOnline => 'Online';

  @override
  String get orderHistoryRetry => 'Retry';

  @override
  String get orderHistoryLoadFailed => 'Could not load data. Please try again.';

  @override
  String get orderHistoryLoadMore => 'Load more';

  @override
  String get promoSlide1Badge => 'LIMITED OFFER';

  @override
  String get promoSlide1Title => 'Sale: 50% off';

  @override
  String get promoSlide1Subtitle => 'All pizzas';

  @override
  String get promoSlide2Badge => 'FAST DELIVERY';

  @override
  String get promoSlide2Title => 'Delivery in 20 minutes';

  @override
  String get promoSlide2Subtitle => 'Hot and fresh dishes';

  @override
  String get promoSlide3Badge => 'TOP MENU';

  @override
  String get promoSlide3Title => 'Burger + drink combo';

  @override
  String get promoSlide3Subtitle => 'Special price today';

  @override
  String get productDescBurger =>
      'Beef patty, iceberg, special sauce — served hot';

  @override
  String get productDescPizza => 'Mozzarella, tomato sauce, herbs — sliced';

  @override
  String get productDescIcecream => 'Delicious ice cream — cold and sweet';

  @override
  String get productDescHotDog => 'Hot sausage, soft bun';

  @override
  String get productDescLavash => 'Lavash filled with meat and vegetables';

  @override
  String get productDescSandwich => 'Toasted bread, sauce and chicken';

  @override
  String get productDescButterbrod => 'Cucumber bread and sausage';

  @override
  String get productDescSalads => 'Fresh vegetables and dressing';

  @override
  String get productDescDrinks => 'Cold drink';

  @override
  String get productDescDessert => 'Sweet dessert';

  @override
  String get productDescDrinksAlt => 'Cool and refreshing';

  @override
  String get productDescDefault => 'Premium ingredients — freshly prepared';
}
