import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

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
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gelion'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @currencySom.
  ///
  /// In en, this message translates to:
  /// **'UZS'**
  String get currencySom;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome! The tastiest food is waiting for you.'**
  String get loginWelcomeSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone or Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'sample@mail.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginDivider.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get loginDivider;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginRegisterLink;

  /// No description provided for @loginGoogleSoon.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in coming soon'**
  String get loginGoogleSoon;

  /// No description provided for @loginAppleSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in coming soon'**
  String get loginAppleSoon;

  /// No description provided for @loginResetEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first to reset password'**
  String get loginResetEnterEmail;

  /// No description provided for @loginResetSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get loginResetSent;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to use the app fully'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullName;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registerPhone;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerButton;

  /// No description provided for @registerDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get registerDivider;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerLoginLink;

  /// No description provided for @registerGoogleSoon.
  ///
  /// In en, this message translates to:
  /// **'Google sign-up coming soon'**
  String get registerGoogleSoon;

  /// No description provided for @registerAppleSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-up coming soon'**
  String get registerAppleSoon;

  /// No description provided for @hintFullName.
  ///
  /// In en, this message translates to:
  /// **'First and last name'**
  String get hintFullName;

  /// No description provided for @hintPhone.
  ///
  /// In en, this message translates to:
  /// **'+998'**
  String get hintPhone;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelPhone;

  /// No description provided for @validationEnterField.
  ///
  /// In en, this message translates to:
  /// **'Please enter {label}'**
  String validationEnterField(String label);

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get validationEnterEmail;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get validationEnterPassword;

  /// No description provided for @validationPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordShort;

  /// No description provided for @validationEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get validationEnterPhone;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationPhoneInvalid;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @validationPasswordNeedUpper.
  ///
  /// In en, this message translates to:
  /// **'Add at least one uppercase letter'**
  String get validationPasswordNeedUpper;

  /// No description provided for @validationPasswordNeedLower.
  ///
  /// In en, this message translates to:
  /// **'Add at least one lowercase letter'**
  String get validationPasswordNeedLower;

  /// No description provided for @validationPasswordNeedDigit.
  ///
  /// In en, this message translates to:
  /// **'Add at least one digit'**
  String get validationPasswordNeedDigit;

  /// No description provided for @validationPasswordNeedSpecial.
  ///
  /// In en, this message translates to:
  /// **'Add at least one special character'**
  String get validationPasswordNeedSpecial;

  /// No description provided for @firebaseErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get firebaseErrorInvalidEmail;

  /// No description provided for @firebaseErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get firebaseErrorUserNotFound;

  /// No description provided for @firebaseErrorWrongCredential.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get firebaseErrorWrongCredential;

  /// No description provided for @firebaseErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get firebaseErrorEmailInUse;

  /// No description provided for @firebaseErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get firebaseErrorWeakPassword;

  /// No description provided for @firebaseErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection.'**
  String get firebaseErrorNetwork;

  /// No description provided for @firebaseErrorAuthGeneric.
  ///
  /// In en, this message translates to:
  /// **'Authentication error.'**
  String get firebaseErrorAuthGeneric;

  /// No description provided for @firebaseErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign out and sign in again, then try once more.'**
  String get firebaseErrorRequiresRecentLogin;

  /// No description provided for @firebaseErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get firebaseErrorTooManyRequests;

  /// No description provided for @firebaseErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Firebase server.'**
  String get firebaseErrorUnavailable;

  /// No description provided for @firebaseErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Firebase error occurred.'**
  String get firebaseErrorGeneric;

  /// No description provided for @firebaseErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred.'**
  String get firebaseErrorUnknown;

  /// No description provided for @firebaseConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Firebase connection error.\n{message}'**
  String firebaseConnectionError(String message);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @firebaseInitError.
  ///
  /// In en, this message translates to:
  /// **'Firebase initialization error: {error}'**
  String firebaseInitError(String error);

  /// No description provided for @firebaseConfigIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Firebase config incomplete (apiKey/appId empty).'**
  String get firebaseConfigIncomplete;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Pizza & Ice Cream'**
  String get splashTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'LOADING...'**
  String get splashLoading;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingProgress.
  ///
  /// In en, this message translates to:
  /// **'ONBOARDING {page}'**
  String onboardingProgress(int page);

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Hot and fresh\npizza'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Our wood-fired pizzas go straight to your door piping hot.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Cold and creamy\nice cream'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Feel the sunshine and silky cream in every spoonful.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Your favorites arrive hot and fresh right at your doorstep.'**
  String get onboarding3Body;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get homeGreeting;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search pizza or ice cream...'**
  String get homeSearchHint;

  /// No description provided for @homeSectionPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular dishes'**
  String get homeSectionPopular;

  /// No description provided for @homeSectionAssortment.
  ///
  /// In en, this message translates to:
  /// **'{category} — assortment'**
  String homeSectionAssortment(String category);

  /// No description provided for @homeProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String homeProductCount(int count);

  /// No description provided for @homeFullList.
  ///
  /// In en, this message translates to:
  /// **'Full list'**
  String get homeFullList;

  /// No description provided for @homeSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results in this category or search. Try another category.'**
  String get homeSearchEmpty;

  /// No description provided for @homeFoodsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dishes yet. Check back soon — new items appear automatically.'**
  String get homeFoodsEmpty;

  /// No description provided for @homeFoodsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load dishes. Check your connection and try again.'**
  String get homeFoodsLoadError;

  /// No description provided for @homeCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get homeCategoriesEmpty;

  /// No description provided for @homeSupportSoon.
  ///
  /// In en, this message translates to:
  /// **'Support — coming soon'**
  String get homeSupportSoon;

  /// No description provided for @homeNotificationsSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications — coming soon'**
  String get homeNotificationsSoon;

  /// No description provided for @homeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategoriesTitle;

  /// No description provided for @homeCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Category page'**
  String get homeCategoryTooltip;

  /// No description provided for @homeCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeCategoryAll;

  /// No description provided for @homeAllFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'All dishes'**
  String get homeAllFoodsTitle;

  /// No description provided for @categoryAssortmentTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} assortment'**
  String categoryAssortmentTitle(String category);

  /// No description provided for @categoryPizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get categoryPizza;

  /// No description provided for @categoryIcecream.
  ///
  /// In en, this message translates to:
  /// **'Ice cream'**
  String get categoryIcecream;

  /// No description provided for @categoryBurger.
  ///
  /// In en, this message translates to:
  /// **'Burger'**
  String get categoryBurger;

  /// No description provided for @categoryHotDog.
  ///
  /// In en, this message translates to:
  /// **'Hot dog'**
  String get categoryHotDog;

  /// No description provided for @categoryLavash.
  ///
  /// In en, this message translates to:
  /// **'Lavash'**
  String get categoryLavash;

  /// No description provided for @categorySandwich.
  ///
  /// In en, this message translates to:
  /// **'Sandwich'**
  String get categorySandwich;

  /// No description provided for @categoryButterbrod.
  ///
  /// In en, this message translates to:
  /// **'Open sandwich'**
  String get categoryButterbrod;

  /// No description provided for @categorySalads.
  ///
  /// In en, this message translates to:
  /// **'Salads'**
  String get categorySalads;

  /// No description provided for @categoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryDrinks;

  /// No description provided for @categorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in this category...'**
  String get categorySearchHint;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// No description provided for @sortCheap.
  ///
  /// In en, this message translates to:
  /// **'Cheap'**
  String get sortCheap;

  /// No description provided for @sortNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get sortNew;

  /// No description provided for @categoryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pcs'**
  String categoryItemCount(int count);

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products in this category yet'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing the search or pick another category.'**
  String get categoryEmptySubtitle;

  /// No description provided for @productIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get productIngredients;

  /// No description provided for @productQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productQuantity;

  /// No description provided for @productRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get productRecommendations;

  /// No description provided for @productDefaultIngredients.
  ///
  /// In en, this message translates to:
  /// **'Premium ingredients'**
  String get productDefaultIngredients;

  /// No description provided for @productAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart — {amount} {currency}'**
  String productAddToCart(String amount, String currency);

  /// No description provided for @productAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} × {qty} added to cart'**
  String productAddedSnack(String name, int qty);

  /// No description provided for @cartTitleBar.
  ///
  /// In en, this message translates to:
  /// **'Gelion'**
  String get cartTitleBar;

  /// No description provided for @cartPromoLabel.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get cartPromoLabel;

  /// No description provided for @cartAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get cartAddressLabel;

  /// No description provided for @cartAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, house, entrance, floor…'**
  String get cartAddressHint;

  /// No description provided for @cartAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter delivery address'**
  String get cartAddressRequired;

  /// No description provided for @cartPromoHint.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get cartPromoHint;

  /// No description provided for @cartPromoApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get cartPromoApply;

  /// No description provided for @cartSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get cartSummaryTitle;

  /// No description provided for @cartRowProducts.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get cartRowProducts;

  /// No description provided for @cartRowDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get cartRowDelivery;

  /// No description provided for @cartRowDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cartRowDiscount;

  /// No description provided for @cartRowTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartRowTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get cartCheckout;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try Melted Monster Burger or Choco Melt Shake — add from home.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartBrowseFoods.
  ///
  /// In en, this message translates to:
  /// **'Browse dishes'**
  String get cartBrowseFoods;

  /// No description provided for @cartPromoEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter a promo code'**
  String get cartPromoEnter;

  /// No description provided for @cartPromo10.
  ///
  /// In en, this message translates to:
  /// **'10% discount applied'**
  String get cartPromo10;

  /// No description provided for @cartPromo5000.
  ///
  /// In en, this message translates to:
  /// **'5,000 UZS discount applied'**
  String get cartPromo5000;

  /// No description provided for @cartPromo15.
  ///
  /// In en, this message translates to:
  /// **'15% discount applied'**
  String get cartPromo15;

  /// No description provided for @cartPromoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Promo code not found'**
  String get cartPromoNotFound;

  /// No description provided for @cartOrderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order accepted ({orderNo}) — {total}'**
  String cartOrderAccepted(String orderNo, String total);

  /// No description provided for @cartOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Order failed. Check internet or your account.'**
  String get cartOrderFailed;

  /// No description provided for @cartAddedSimple.
  ///
  /// In en, this message translates to:
  /// **'{name} added to cart'**
  String cartAddedSimple(String name);

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoTitle;

  /// No description provided for @profilePhotoCropDone.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get profilePhotoCropDone;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get profilePhotoCameraHint;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'Pick from your device'**
  String get profilePhotoGalleryHint;

  /// No description provided for @profilePhotoPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Enable it in Settings.'**
  String get profilePhotoPermissionDenied;

  /// No description provided for @profilePhotoDefault.
  ///
  /// In en, this message translates to:
  /// **'Default avatar'**
  String get profilePhotoDefault;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get profilePhotoUploading;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo. Try again.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @profilePhotoUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded successfully'**
  String get profilePhotoUploadSuccess;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm sign out'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileLogoutMessage;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogout;

  /// No description provided for @profileCartHintSnack.
  ///
  /// In en, this message translates to:
  /// **'Open cart from the bottom bar'**
  String get profileCartHintSnack;

  /// No description provided for @profileEditPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get profileEditPhoto;

  /// No description provided for @profileAvatarPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose avatar'**
  String get profileAvatarPickTitle;

  /// No description provided for @profileAvatarPickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a category, then tap an image'**
  String get profileAvatarPickSubtitle;

  /// No description provided for @profileAvatarPickBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get profileAvatarPickBack;

  /// No description provided for @profileAvatarPickEmpty.
  ///
  /// In en, this message translates to:
  /// **'No avatars in this category'**
  String get profileAvatarPickEmpty;

  /// No description provided for @profileGoldMember.
  ///
  /// In en, this message translates to:
  /// **'⭐ Gold member'**
  String get profileGoldMember;

  /// No description provided for @profileOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get profileOrdersTitle;

  /// No description provided for @profileOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View past orders'**
  String get profileOrdersSubtitle;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App settings and security'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTitle;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get settingsSectionPersonal;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get settingsFullName;

  /// No description provided for @settingsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get settingsPhone;

  /// No description provided for @settingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSave;

  /// No description provided for @settingsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get settingsSaving;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get settingsSaved;

  /// No description provided for @settingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check connection and try again.'**
  String get settingsSaveError;

  /// No description provided for @settingsVerifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new email from the inbox link.'**
  String get settingsVerifyEmailSent;

  /// No description provided for @settingsPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsPasswordChange;

  /// No description provided for @settingsPasswordChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current password required'**
  String get settingsPasswordChangeSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we use your data'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTerms;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules for using the app'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get settingsCouldNotOpenLink;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get changePasswordSuccessTitle;

  /// No description provided for @changePasswordSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed successfully.'**
  String get changePasswordSuccessBody;

  /// No description provided for @changePasswordDone.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get changePasswordDone;

  /// No description provided for @settingsSectionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsSectionFeedback;

  /// No description provided for @feedbackSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSendTitle;

  /// No description provided for @feedbackSendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate us and share your thoughts'**
  String get feedbackSendSubtitle;

  /// No description provided for @feedbackPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackPageTitle;

  /// No description provided for @feedbackYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get feedbackYourRating;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your comment'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What went well or what can we improve? (min. 10 characters)'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSubmit;

  /// No description provided for @feedbackSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get feedbackSuccessTitle;

  /// No description provided for @feedbackSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your feedback has been received.'**
  String get feedbackSuccessBody;

  /// No description provided for @feedbackSuccessOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get feedbackSuccessOk;

  /// No description provided for @feedbackValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your comment'**
  String get feedbackValidationEmpty;

  /// No description provided for @feedbackValidationMin10.
  ///
  /// In en, this message translates to:
  /// **'At least 10 characters'**
  String get feedbackValidationMin10;

  /// No description provided for @adminFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get adminFeedbackTitle;

  /// No description provided for @adminFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All feedback (admin)'**
  String get adminFeedbackSubtitle;

  /// No description provided for @adminFeedbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get adminFeedbackEmpty;

  /// No description provided for @adminFeedbackDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this feedback?'**
  String get adminFeedbackDeleteTitle;

  /// No description provided for @adminFeedbackDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get adminFeedbackDeleteBody;

  /// No description provided for @adminFeedbackDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminFeedbackDelete;

  /// No description provided for @adminFeedbackMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get adminFeedbackMarkRead;

  /// No description provided for @adminFeedbackMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get adminFeedbackMarkUnread;

  /// No description provided for @adminFeedbackDeleted.
  ///
  /// In en, this message translates to:
  /// **'Feedback deleted'**
  String get adminFeedbackDeleted;

  /// No description provided for @adminFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Foods (admin)'**
  String get adminFoodsTitle;

  /// No description provided for @adminFoodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage images and prices'**
  String get adminFoodsSubtitle;

  /// No description provided for @adminFoodsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No foods yet'**
  String get adminFoodsEmpty;

  /// No description provided for @adminFoodAdd.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get adminFoodAdd;

  /// No description provided for @adminFoodEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit food'**
  String get adminFoodEdit;

  /// No description provided for @adminFoodSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminFoodSave;

  /// No description provided for @adminFoodCreate.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get adminFoodCreate;

  /// No description provided for @adminFoodImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a food image'**
  String get adminFoodImageRequired;

  /// No description provided for @adminFoodSaved.
  ///
  /// In en, this message translates to:
  /// **'Food saved'**
  String get adminFoodSaved;

  /// No description provided for @adminFoodName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminFoodName;

  /// No description provided for @adminFoodPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminFoodPrice;

  /// No description provided for @adminFoodStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get adminFoodStock;

  /// No description provided for @adminFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminFoodDescription;

  /// No description provided for @adminFoodCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get adminFoodCategory;

  /// No description provided for @adminFoodPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get adminFoodPopular;

  /// No description provided for @adminFoodActive.
  ///
  /// In en, this message translates to:
  /// **'Active (visible in app)'**
  String get adminFoodActive;

  /// No description provided for @adminFoodDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this food?'**
  String get adminFoodDeleteTitle;

  /// No description provided for @adminFoodDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get adminFoodDeleteBody;

  /// No description provided for @adminFoodIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get adminFoodIngredients;

  /// No description provided for @adminFoodRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get adminFoodRecommended;

  /// No description provided for @adminCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories (admin)'**
  String get adminCategoriesTitle;

  /// No description provided for @adminCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage menu categories'**
  String get adminCategoriesSubtitle;

  /// No description provided for @adminCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get adminCategoriesEmpty;

  /// No description provided for @adminCategoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get adminCategoryAdd;

  /// No description provided for @adminCategoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get adminCategoryEdit;

  /// No description provided for @adminCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminCategoryName;

  /// No description provided for @adminCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminCategoryDescription;

  /// No description provided for @adminCategoryOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get adminCategoryOrder;

  /// No description provided for @adminCategoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon key'**
  String get adminCategoryIcon;

  /// No description provided for @adminCategorySaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get adminCategorySaved;

  /// No description provided for @adminCategoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this category?'**
  String get adminCategoryDeleteTitle;

  /// No description provided for @adminCategoryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get adminCategoryDeleteBody;

  /// No description provided for @adminBannersTitle.
  ///
  /// In en, this message translates to:
  /// **'Banners (admin)'**
  String get adminBannersTitle;

  /// No description provided for @adminBannersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Home page promos'**
  String get adminBannersSubtitle;

  /// No description provided for @adminBannersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No banners yet'**
  String get adminBannersEmpty;

  /// No description provided for @adminBannerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add banner'**
  String get adminBannerAdd;

  /// No description provided for @adminBannerEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit banner'**
  String get adminBannerEdit;

  /// No description provided for @adminBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminBannerTitle;

  /// No description provided for @adminBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get adminBannerSubtitle;

  /// No description provided for @adminBannerButton.
  ///
  /// In en, this message translates to:
  /// **'Button text'**
  String get adminBannerButton;

  /// No description provided for @adminBannerLink.
  ///
  /// In en, this message translates to:
  /// **'Link (category:ID or product:ID)'**
  String get adminBannerLink;

  /// No description provided for @adminBannerImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a banner image'**
  String get adminBannerImageRequired;

  /// No description provided for @adminBannerSaved.
  ///
  /// In en, this message translates to:
  /// **'Banner saved'**
  String get adminBannerSaved;

  /// No description provided for @adminBannerDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this banner?'**
  String get adminBannerDeleteTitle;

  /// No description provided for @adminBannerDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get adminBannerDeleteBody;

  /// No description provided for @searchTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTabTitle;

  /// No description provided for @searchTabHint.
  ///
  /// In en, this message translates to:
  /// **'Search by product name…'**
  String get searchTabHint;

  /// No description provided for @searchTabEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products yet.'**
  String get searchTabEmpty;

  /// No description provided for @searchTabNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchTabNoResults;

  /// No description provided for @productStockLimit.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock for {name}'**
  String productStockLimit(String name);

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{name} is not available'**
  String productUnavailable(String name);

  /// No description provided for @productOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'{name} is out of stock'**
  String productOutOfStock(String name);

  /// No description provided for @productOutOfStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productOutOfStockLabel;

  /// No description provided for @adminFoodStockHint.
  ///
  /// In en, this message translates to:
  /// **'Empty = unlimited, 0 = sold out'**
  String get adminFoodStockHint;

  /// No description provided for @adminBannerDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount label'**
  String get adminBannerDiscount;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved dishes'**
  String get favoritesSubtitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmpty;

  /// No description provided for @retryLoad.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLoad;

  /// No description provided for @adminOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminOrdersTitle;

  /// No description provided for @adminOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage customer orders in real time'**
  String get adminOrdersSubtitle;

  /// No description provided for @adminOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get adminOrdersEmpty;

  /// No description provided for @adminOrdersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load orders'**
  String get adminOrdersLoadError;

  /// No description provided for @adminOrderCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get adminOrderCustomer;

  /// No description provided for @adminOrderPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminOrderPhone;

  /// No description provided for @adminOrderDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get adminOrderDeliveryAddress;

  /// No description provided for @adminOrderItems.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get adminOrderItems;

  /// No description provided for @adminOrderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get adminOrderStatusLabel;

  /// No description provided for @adminOrderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get adminOrderStatusUpdated;

  /// No description provided for @adminOrderStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update status'**
  String get adminOrderStatusFailed;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusDelivering.
  ///
  /// In en, this message translates to:
  /// **'Delivering'**
  String get orderStatusDelivering;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistoryTitle;

  /// No description provided for @orderHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderHistoryEmpty;

  /// No description provided for @orderHistoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here after checkout'**
  String get orderHistoryEmptyHint;

  /// No description provided for @orderHistoryAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your orders'**
  String get orderHistoryAuthRequired;

  /// No description provided for @orderHistoryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String orderHistoryItemCount(int count);

  /// No description provided for @orderHistoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} {currency}'**
  String orderHistoryTotal(String amount, String currency);

  /// No description provided for @orderDetailPlacedAt.
  ///
  /// In en, this message translates to:
  /// **'Order time'**
  String get orderDetailPlacedAt;

  /// No description provided for @orderDetailTimeline.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderDetailTimeline;

  /// No description provided for @orderHistoryOrder.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderHistoryOrder(String id);

  /// No description provided for @orderHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'{count} items · {amount} {currency}'**
  String orderHistoryLine(int count, int amount, String currency);

  /// No description provided for @promoSlide1Badge.
  ///
  /// In en, this message translates to:
  /// **'LIMITED OFFER'**
  String get promoSlide1Badge;

  /// No description provided for @promoSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Sale: 50% off'**
  String get promoSlide1Title;

  /// No description provided for @promoSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'All pizzas'**
  String get promoSlide1Subtitle;

  /// No description provided for @promoSlide2Badge.
  ///
  /// In en, this message translates to:
  /// **'FAST DELIVERY'**
  String get promoSlide2Badge;

  /// No description provided for @promoSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Delivery in 20 minutes'**
  String get promoSlide2Title;

  /// No description provided for @promoSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Hot and fresh dishes'**
  String get promoSlide2Subtitle;

  /// No description provided for @promoSlide3Badge.
  ///
  /// In en, this message translates to:
  /// **'TOP MENU'**
  String get promoSlide3Badge;

  /// No description provided for @promoSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Burger + drink combo'**
  String get promoSlide3Title;

  /// No description provided for @promoSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Special price today'**
  String get promoSlide3Subtitle;

  /// No description provided for @productDescBurger.
  ///
  /// In en, this message translates to:
  /// **'Beef patty, iceberg, special sauce — served hot'**
  String get productDescBurger;

  /// No description provided for @productDescPizza.
  ///
  /// In en, this message translates to:
  /// **'Mozzarella, tomato sauce, herbs — sliced'**
  String get productDescPizza;

  /// No description provided for @productDescIcecream.
  ///
  /// In en, this message translates to:
  /// **'Delicious ice cream — cold and sweet'**
  String get productDescIcecream;

  /// No description provided for @productDescHotDog.
  ///
  /// In en, this message translates to:
  /// **'Hot sausage, soft bun'**
  String get productDescHotDog;

  /// No description provided for @productDescLavash.
  ///
  /// In en, this message translates to:
  /// **'Lavash filled with meat and vegetables'**
  String get productDescLavash;

  /// No description provided for @productDescSandwich.
  ///
  /// In en, this message translates to:
  /// **'Toasted bread, sauce and chicken'**
  String get productDescSandwich;

  /// No description provided for @productDescButterbrod.
  ///
  /// In en, this message translates to:
  /// **'Cucumber bread and sausage'**
  String get productDescButterbrod;

  /// No description provided for @productDescSalads.
  ///
  /// In en, this message translates to:
  /// **'Fresh vegetables and dressing'**
  String get productDescSalads;

  /// No description provided for @productDescDrinks.
  ///
  /// In en, this message translates to:
  /// **'Cold drink'**
  String get productDescDrinks;

  /// No description provided for @productDescDessert.
  ///
  /// In en, this message translates to:
  /// **'Sweet dessert'**
  String get productDescDessert;

  /// No description provided for @productDescDrinksAlt.
  ///
  /// In en, this message translates to:
  /// **'Cool and refreshing'**
  String get productDescDrinksAlt;

  /// No description provided for @productDescDefault.
  ///
  /// In en, this message translates to:
  /// **'Premium ingredients — freshly prepared'**
  String get productDescDefault;
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
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
