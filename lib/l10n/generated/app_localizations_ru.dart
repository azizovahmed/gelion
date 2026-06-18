// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Gelion';

  @override
  String get navHome => 'Главная';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navCart => 'Корзина';

  @override
  String get navProfile => 'Профиль';

  @override
  String get currencySom => 'сум';

  @override
  String get guestName => 'Гость';

  @override
  String get loginWelcomeSubtitle =>
      'Добро пожаловать! Самая вкусная еда ждёт вас.';

  @override
  String get loginEmailLabel => 'Телефон или Email';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginEmailHint => 'sample@mail.com';

  @override
  String get loginPasswordHint => '••••••';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginDivider => 'ИЛИ ПРОДОЛЖИТЬ С';

  @override
  String get loginNoAccount => 'Нет аккаунта? ';

  @override
  String get loginRegisterLink => 'Регистрация';

  @override
  String get loginGoogleSoon => 'Вход через Google скоро';

  @override
  String get loginAppleSoon => 'Вход через Apple скоро';

  @override
  String get loginResetEnterEmail => 'Сначала введите email для сброса пароля';

  @override
  String get loginResetSent => 'Ссылка для сброса отправлена на email';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Создайте аккаунт для полного доступа';

  @override
  String get registerFullName => 'Полное имя';

  @override
  String get registerPhone => 'Номер телефона';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Пароль';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get registerDivider => 'ИЛИ';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get registerLoginLink => 'Войти';

  @override
  String get registerGoogleSoon => 'Регистрация через Google скоро';

  @override
  String get registerAppleSoon => 'Регистрация через Apple скоро';

  @override
  String get hintFullName => 'Имя и фамилия';

  @override
  String get hintPhone => '+998';

  @override
  String get labelName => 'Имя';

  @override
  String get labelPhone => 'Телефон';

  @override
  String validationEnterField(String label) {
    return 'Введите $label';
  }

  @override
  String get validationEnterEmail => 'Введите email';

  @override
  String get validationEmailInvalid => 'Неверный email';

  @override
  String get validationEnterPassword => 'Введите пароль';

  @override
  String get validationPasswordShort => 'Пароль не короче 6 символов';

  @override
  String get validationEnterPhone => 'Введите номер телефона';

  @override
  String get validationPhoneInvalid => 'Введите корректный номер';

  @override
  String get validationPasswordMismatch => 'Пароли не совпадают';

  @override
  String get validationPasswordNeedUpper =>
      'Добавьте хотя бы одну заглавную букву';

  @override
  String get validationPasswordNeedLower =>
      'Добавьте хотя бы одну строчную букву';

  @override
  String get validationPasswordNeedDigit => 'Добавьте хотя бы одну цифру';

  @override
  String get validationPasswordNeedSpecial =>
      'Добавьте хотя бы один спецсимвол';

  @override
  String get firebaseErrorInvalidEmail => 'Неверный формат email.';

  @override
  String get firebaseErrorUserNotFound => 'Пользователь не найден.';

  @override
  String get firebaseErrorWrongCredential => 'Неверный email или пароль.';

  @override
  String get firebaseErrorEmailInUse => 'Этот email уже зарегистрирован.';

  @override
  String get firebaseErrorWeakPassword => 'Слишком слабый пароль.';

  @override
  String get firebaseErrorNetwork => 'Проверьте подключение к интернету.';

  @override
  String get firebaseErrorAuthGeneric => 'Ошибка аутентификации.';

  @override
  String get firebaseErrorRequiresRecentLogin =>
      'Выйдите из аккаунта, войдите снова и повторите попытку.';

  @override
  String get firebaseErrorTooManyRequests =>
      'Слишком много попыток. Попробуйте позже.';

  @override
  String get firebaseErrorUnavailable =>
      'Не удалось подключиться к серверу Firebase.';

  @override
  String get firebaseErrorGeneric => 'Ошибка Firebase.';

  @override
  String get firebaseErrorUnknown => 'Произошла неизвестная ошибка.';

  @override
  String firebaseConnectionError(String message) {
    return 'Ошибка подключения Firebase.\n$message';
  }

  @override
  String get retry => 'Повторить';

  @override
  String firebaseInitError(String error) {
    return 'Ошибка инициализации Firebase: $error';
  }

  @override
  String get firebaseConfigIncomplete =>
      'Конфигурация Firebase неполная (пустой apiKey/appId).';

  @override
  String get splashTagline => 'Пицца и мороженое';

  @override
  String get splashLoading => 'ЗАГРУЗКА...';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String onboardingProgress(int page) {
    return 'ОНБОРДИНГ $page';
  }

  @override
  String get onboarding1Title => 'Горячая и свежая\nпицца';

  @override
  String get onboarding1Body =>
      'Наши пиццы из печи приезжают к вам горячими прямо к двери.';

  @override
  String get onboarding2Title => 'Холодное и нежное\nмороженое';

  @override
  String get onboarding2Body => 'Солнечный день и нежный крем в каждой ложке.';

  @override
  String get onboarding3Title => 'Быстрая доставка';

  @override
  String get onboarding3Body =>
      'Любимые блюда горячими и свежими прямо к вашему порогу.';

  @override
  String get homeGreeting => 'Здравствуйте 👋';

  @override
  String get homeSearchHint => 'Ищите пиццу или мороженое...';

  @override
  String get homeSectionPopular => 'Популярные блюда';

  @override
  String homeSectionAssortment(String category) {
    return '$category — ассортимент';
  }

  @override
  String homeProductCount(int count) {
    return '$count товаров';
  }

  @override
  String get homeFullList => 'Полный список';

  @override
  String get homeSearchEmpty =>
      'Нет результатов в категории или поиске. Выберите другую категорию.';

  @override
  String get homeFoodsEmpty =>
      'Пока нет блюд. Новые позиции появятся автоматически.';

  @override
  String get homeFoodsLoadError =>
      'Не удалось загрузить блюда. Проверьте интернет и повторите.';

  @override
  String get homeCategoriesEmpty => 'Категорий пока нет';

  @override
  String get homeSupportSoon => 'Поддержка — скоро';

  @override
  String get homeNotificationsSoon => 'Уведомления — скоро';

  @override
  String get homeCategoriesTitle => 'Категории';

  @override
  String get homeCategoryTooltip => 'Страница категории';

  @override
  String get homeCategoryAll => 'Все';

  @override
  String get homeAllFoodsTitle => 'Все блюда';

  @override
  String categoryAssortmentTitle(String category) {
    return 'Ассортимент $category';
  }

  @override
  String get categoryPizza => 'Пицца';

  @override
  String get categoryIcecream => 'Мороженое';

  @override
  String get categoryBurger => 'Бургер';

  @override
  String get categoryHotDog => 'Хот-дог';

  @override
  String get categoryLavash => 'Лаваш';

  @override
  String get categorySandwich => 'Сэндвич';

  @override
  String get categoryButterbrod => 'Бутерброд';

  @override
  String get categorySalads => 'Салаты';

  @override
  String get categoryDrinks => 'Напитки';

  @override
  String get categorySearchHint => 'Поиск в этой категории...';

  @override
  String get sortPopular => 'Популярное';

  @override
  String get sortCheap => 'Дешевле';

  @override
  String get sortNew => 'Новинки';

  @override
  String categoryItemCount(int count) {
    return '$count шт';
  }

  @override
  String get categoryEmptyTitle => 'В этой категории пока нет товаров';

  @override
  String get categoryEmptySubtitle =>
      'Измените поиск или выберите другую категорию.';

  @override
  String get productIngredients => 'Состав';

  @override
  String get productQuantity => 'Количество';

  @override
  String get productRecommendations => 'Рекомендуем';

  @override
  String get productDefaultIngredients => 'Премиальные ингредиенты';

  @override
  String productAddToCart(String amount, String currency) {
    return 'В корзину — $amount $currency';
  }

  @override
  String productAddedSnack(String name, int qty) {
    return '$name × $qty добавлено в корзину';
  }

  @override
  String get cartTitleBar => 'Gelion';

  @override
  String get cartPromoLabel => 'Промокод';

  @override
  String get cartAddressLabel => 'Адрес доставки';

  @override
  String get cartAddressHint => 'Улица, дом, подъезд, этаж…';

  @override
  String get cartAddressRequired => 'Укажите адрес доставки';

  @override
  String get cartPromoHint => 'Промокод';

  @override
  String get cartPromoApply => 'Применить';

  @override
  String get cartSummaryTitle => 'Итого';

  @override
  String get cartRowProducts => 'Товары';

  @override
  String get cartRowDelivery => 'Доставка';

  @override
  String get cartRowDiscount => 'Скидка';

  @override
  String get cartRowTotal => 'Всего';

  @override
  String get cartCheckout => 'Оформить заказ';

  @override
  String get cartEmptyTitle => 'Корзина пуста';

  @override
  String get cartEmptySubtitle =>
      'Например: Melted Monster Burger или Choco Melt Shake — добавьте с главной.';

  @override
  String get cartBrowseFoods => 'Смотреть меню';

  @override
  String get cartPromoEnter => 'Введите промокод';

  @override
  String get cartPromo10 => 'Применена скидка 10%';

  @override
  String get cartPromo5000 => 'Применена скидка 5 000 сум';

  @override
  String get cartPromo15 => 'Применена скидка 15%';

  @override
  String get cartPromoNotFound => 'Промокод не найден';

  @override
  String cartOrderAccepted(String orderNo, String total) {
    return 'Заказ принят ($orderNo) — $total';
  }

  @override
  String get cartOrderSuccessTitle => 'Заказ принят!';

  @override
  String cartOrderSuccessMessage(String orderNo, String total) {
    return 'Номер заказа: $orderNo\nИтого: $total';
  }

  @override
  String get cartOrderSuccessOk => 'Хорошо';

  @override
  String get cartOrderFailed =>
      'Заказ не отправлен. Проверьте интернет или аккаунт.';

  @override
  String cartAddedSimple(String name) {
    return '$name добавлено в корзину';
  }

  @override
  String get profilePhotoTitle => 'Фото профиля';

  @override
  String get profilePhotoCropDone => 'Обрезать';

  @override
  String get profilePhotoCamera => 'Камера';

  @override
  String get profilePhotoCameraHint => 'Сделать новое фото';

  @override
  String get profilePhotoGallery => 'Галерея';

  @override
  String get profilePhotoGalleryHint => 'Выбрать с устройства';

  @override
  String get profilePhotoFiles => 'Файлы';

  @override
  String get profilePhotoFilesHint => 'Выбрать файл с устройства';

  @override
  String get profilePhotoPermissionDenied =>
      'Нет доступа. Включите в настройках.';

  @override
  String get profilePhotoDefault => 'Стандартный аватар';

  @override
  String get profilePhotoUpdated => 'Фото профиля обновлено';

  @override
  String get profilePhotoUploading => 'Загрузка фото…';

  @override
  String get profilePhotoUploadFailed => 'Не удалось загрузить фото';

  @override
  String get profilePhotoRemove => 'Удалить фото';

  @override
  String get profilePhotoUploadSuccess => 'Фото успешно загружено';

  @override
  String get profileLogoutTitle => 'Подтвердите выход';

  @override
  String get profileLogoutMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get profileCancel => 'Отмена';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileCartHintSnack => 'Корзина открывается с нижней панели';

  @override
  String get profileEditPhoto => 'Изменить фото';

  @override
  String get profileAvatarPickTitle => 'Выберите аватар';

  @override
  String get profileAvatarPickSubtitle =>
      'Сначала категория, затем изображение';

  @override
  String get profileAvatarPickBack => 'Назад';

  @override
  String get profileAvatarPickEmpty => 'В этой категории нет аватаров';

  @override
  String get profileGoldMember => '⭐ Золотой участник';

  @override
  String get profileOrdersTitle => 'История заказов';

  @override
  String get profileOrdersSubtitle => 'Просмотр прошлых заказов';

  @override
  String get profileSettingsTitle => 'Настройки';

  @override
  String get profileSettingsSubtitle => 'Настройки и безопасность';

  @override
  String get profileLanguageTitle => 'Язык';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'День';

  @override
  String get settingsThemeDark => 'Ночь';

  @override
  String get settingsSectionPersonal => 'Личные данные';

  @override
  String get settingsSectionSecurity => 'Безопасность';

  @override
  String get settingsSectionAbout => 'О приложении';

  @override
  String get settingsFullName => 'Имя и фамилия';

  @override
  String get settingsPhone => 'Телефон';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsSave => 'Сохранить';

  @override
  String get settingsSaving => 'Сохранение…';

  @override
  String get settingsSaved => 'Профиль обновлён';

  @override
  String get settingsSaveError =>
      'Не удалось сохранить. Проверьте сеть и попробуйте снова.';

  @override
  String get settingsVerifyEmailSent =>
      'Перейдите по ссылке в письме на новый email.';

  @override
  String get settingsPasswordChange => 'Сменить пароль';

  @override
  String get settingsPasswordChangeSubtitle => 'Нужен текущий пароль';

  @override
  String get settingsPrivacy => 'Политика конфиденциальности';

  @override
  String get settingsPrivacySubtitle => 'Как мы используем данные';

  @override
  String get settingsTerms => 'Условия использования';

  @override
  String get settingsTermsSubtitle => 'Правила приложения';

  @override
  String get settingsCouldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get changePasswordTitle => 'Смена пароля';

  @override
  String get changePasswordCurrent => 'Текущий пароль';

  @override
  String get changePasswordNew => 'Новый пароль';

  @override
  String get changePasswordConfirm => 'Подтвердите пароль';

  @override
  String get changePasswordSubmit => 'Обновить пароль';

  @override
  String get changePasswordSuccessTitle => 'Пароль обновлён';

  @override
  String get changePasswordSuccessBody => 'Пароль успешно изменён.';

  @override
  String get changePasswordDone => 'ОК';

  @override
  String get settingsSectionFeedback => 'Отзывы';

  @override
  String get feedbackSendTitle => 'Отправить отзыв';

  @override
  String get feedbackSendSubtitle => 'Оцените и напишите комментарий';

  @override
  String get feedbackPageTitle => 'Отзыв';

  @override
  String get feedbackYourRating => 'Ваша оценка';

  @override
  String get feedbackMessageLabel => 'Комментарий';

  @override
  String get feedbackMessageHint =>
      'Что понравилось или что улучшить? (мин. 10 символов)';

  @override
  String get feedbackSubmit => 'Отправить';

  @override
  String get feedbackSuccessTitle => 'Спасибо!';

  @override
  String get feedbackSuccessBody => 'Ваш отзыв получен.';

  @override
  String get feedbackSuccessOk => 'ОК';

  @override
  String get feedbackValidationEmpty => 'Введите текст';

  @override
  String get feedbackValidationMin10 => 'Не менее 10 символов';

  @override
  String get adminFeedbackTitle => 'Отзывы';

  @override
  String get adminFeedbackSubtitle => 'Все отзывы (админ)';

  @override
  String get adminFeedbackEmpty => 'Пока нет отзывов';

  @override
  String get adminFeedbackDeleteTitle => 'Удалить отзыв?';

  @override
  String get adminFeedbackDeleteBody => 'Действие нельзя отменить.';

  @override
  String get adminFeedbackDelete => 'Удалить';

  @override
  String get adminFeedbackMarkRead => 'Прочитано';

  @override
  String get adminFeedbackMarkUnread => 'Не прочитано';

  @override
  String get adminFeedbackDeleted => 'Отзыв удалён';

  @override
  String get adminFoodsTitle => 'Блюда (админ)';

  @override
  String get adminFoodsSubtitle => 'Управление фото и ценами';

  @override
  String get adminFoodsEmpty => 'Пока нет блюд';

  @override
  String get adminFoodAdd => 'Добавить блюдо';

  @override
  String get adminFoodEdit => 'Редактировать';

  @override
  String get adminFoodSave => 'Сохранить';

  @override
  String get adminFoodCreate => 'Создать товар';

  @override
  String get adminFoodImageRequired => 'Выберите фото блюда';

  @override
  String get adminFoodSaved => 'Блюдо сохранено';

  @override
  String get adminFoodName => 'Название';

  @override
  String get adminFoodPrice => 'Цена';

  @override
  String get adminFoodStock => 'Запас';

  @override
  String get adminFoodDescription => 'Описание';

  @override
  String get adminFoodCategory => 'Категория';

  @override
  String get adminFoodPopular => 'Популярное';

  @override
  String get adminFoodActive => 'Активно (в приложении)';

  @override
  String get adminFoodDeleteTitle => 'Удалить блюдо?';

  @override
  String get adminFoodDeleteBody => 'Это действие нельзя отменить.';

  @override
  String get adminFoodIngredients => 'Состав (ингредиенты)';

  @override
  String get adminFoodRecommended => 'Рекомендуем';

  @override
  String get adminCategoriesTitle => 'Категории (админ)';

  @override
  String get adminCategoriesSubtitle => 'Управление категориями меню';

  @override
  String get adminCategoriesEmpty => 'Пока нет категорий';

  @override
  String get adminCategoryAdd => 'Добавить категорию';

  @override
  String get adminCategoryEdit => 'Редактировать категорию';

  @override
  String get adminCategoryName => 'Название';

  @override
  String get adminCategoryDescription => 'Описание';

  @override
  String get adminCategoryOrder => 'Порядок';

  @override
  String get adminCategoryIcon => 'Ключ иконки';

  @override
  String get adminCategorySaved => 'Категория сохранена';

  @override
  String get adminCategoryDeleteTitle => 'Удалить категорию?';

  @override
  String get adminCategoryDeleteBody => 'Это действие нельзя отменить.';

  @override
  String get adminBannersTitle => 'Баннеры (админ)';

  @override
  String get adminBannersSubtitle => 'Промо на главной';

  @override
  String get adminBannersEmpty => 'Пока нет баннеров';

  @override
  String get adminBannerAdd => 'Добавить баннер';

  @override
  String get adminBannerEdit => 'Редактировать баннер';

  @override
  String get adminBannerChangeImage => 'Изменить изображение';

  @override
  String get adminBannerTitle => 'Заголовок';

  @override
  String get adminBannerSubtitle => 'Подзаголовок';

  @override
  String get adminBannerButton => 'Текст кнопки';

  @override
  String get adminBannerLink => 'Ссылка (category:ID или product:ID)';

  @override
  String get adminBannerImageRequired => 'Выберите изображение баннера';

  @override
  String get adminBannerSaved => 'Баннер сохранён';

  @override
  String get adminBannerDeleteTitle => 'Удалить баннер?';

  @override
  String get adminBannerDeleteBody => 'Это действие нельзя отменить.';

  @override
  String get searchTabTitle => 'Поиск';

  @override
  String get searchTabHint => 'Поиск по названию…';

  @override
  String get searchTabEmpty => 'Пока нет товаров.';

  @override
  String get searchTabNoResults => 'Ничего не найдено.';

  @override
  String productStockLimit(String name) {
    return 'Недостаточно запаса: $name';
  }

  @override
  String productUnavailable(String name) {
    return '$name недоступен';
  }

  @override
  String productOutOfStock(String name) {
    return '$name закончился';
  }

  @override
  String get productOutOfStockLabel => 'Нет в наличии';

  @override
  String get adminFoodStockHint => 'Пусто = без лимита, 0 = нет в наличии';

  @override
  String get adminBannerDiscount => 'Текст скидки';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesSubtitle => 'Сохранённые блюда';

  @override
  String get favoritesEmpty => 'Пока нет избранного';

  @override
  String get retryLoad => 'Повторить';

  @override
  String get adminOrdersTitle => 'Заказы';

  @override
  String get adminOrdersSubtitle => 'Управление заказами в реальном времени';

  @override
  String get adminOrdersEmpty => 'Заказов пока нет';

  @override
  String get adminOrdersLoadError => 'Не удалось загрузить заказы';

  @override
  String get adminOrderCustomer => 'Клиент';

  @override
  String get adminOrderPhone => 'Телефон';

  @override
  String get adminOrderDeliveryAddress => 'Адрес доставки';

  @override
  String get adminOrderItems => 'Состав заказа';

  @override
  String get adminOrderStatusLabel => 'Статус заказа';

  @override
  String get adminOrderStatusUpdated => 'Статус обновлён';

  @override
  String get adminOrderStatusFailed => 'Не удалось обновить статус';

  @override
  String get orderStatusPending => 'Ожидает';

  @override
  String get orderStatusAccepted => 'Принят';

  @override
  String get orderStatusPreparing => 'Готовится';

  @override
  String get orderStatusDelivering => 'Доставляется';

  @override
  String get orderStatusCompleted => 'Завершён';

  @override
  String get orderStatusCancelled => 'Отменён';

  @override
  String get orderHistoryTitle => 'История заказов';

  @override
  String get orderHistoryEmpty => 'У вас пока нет заказов';

  @override
  String get orderHistoryEmptyHint => 'После оформления заказы появятся здесь';

  @override
  String get orderHistoryAuthRequired => 'Войдите, чтобы видеть заказы';

  @override
  String orderHistoryItemCount(int count) {
    return '$count товаров';
  }

  @override
  String orderHistoryTotal(String amount, String currency) {
    return 'Итого: $amount $currency';
  }

  @override
  String get orderDetailPlacedAt => 'Время заказа';

  @override
  String get orderDetailTimeline => 'Статус заказа';

  @override
  String orderHistoryOrder(String id) {
    return 'Заказ #$id';
  }

  @override
  String orderHistoryLine(int count, int amount, String currency) {
    return '$count товаров • $amount $currency';
  }

  @override
  String get orderHistoryPlaceOrder => 'Оформить заказ';

  @override
  String get orderHistorySearchHint => 'Номер заказа (#CM...)';

  @override
  String get orderFilterAll => 'Все';

  @override
  String get orderFilterToday => 'Сегодня';

  @override
  String get orderFilterWeek => '7 дней';

  @override
  String get orderFilterMonth => '30 дней';

  @override
  String get orderHistoryOffline => 'Офлайн — сохранённые заказы';

  @override
  String get orderDetailPayment => 'Способ оплаты';

  @override
  String get orderPaymentCash => 'Наличные';

  @override
  String get orderPaymentCard => 'Карта';

  @override
  String get orderPaymentOnline => 'Онлайн';

  @override
  String get orderHistoryRetry => 'Повторить';

  @override
  String get orderHistoryLoadFailed =>
      'Не удалось загрузить данные. Попробуйте снова.';

  @override
  String get orderHistoryLoadMore => 'Загрузить ещё';

  @override
  String get promoSlide1Badge => 'АКЦИЯ';

  @override
  String get promoSlide1Title => 'Скидка 50%';

  @override
  String get promoSlide1Subtitle => 'На всю пиццу';

  @override
  String get promoSlide2Badge => 'БЫСТРАЯ ДОСТАВКА';

  @override
  String get promoSlide2Title => 'За 20 минут';

  @override
  String get promoSlide2Subtitle => 'Горячие свежие блюда';

  @override
  String get promoSlide3Badge => 'ТОП МЕНЮ';

  @override
  String get promoSlide3Title => 'Комбо бургер + напиток';

  @override
  String get promoSlide3Subtitle => 'Спеццена сегодня';

  @override
  String get productDescBurger => 'Котлета, айсберг, фирменный соус — горячим';

  @override
  String get productDescPizza => 'Моцарелла, томатный соус, специи';

  @override
  String get productDescIcecream => 'Вкусное мороженое — холодное и сладкое';

  @override
  String get productDescHotDog => 'Горячая сосиска, мягкая булка';

  @override
  String get productDescLavash => 'Лаваш с мясом и овощами';

  @override
  String get productDescSandwich => 'Тост, соус и курица';

  @override
  String get productDescButterbrod => 'Хлеб с огурцом и колбасой';

  @override
  String get productDescSalads => 'Свежие овощи и заправка';

  @override
  String get productDescDrinks => 'Холодный напиток';

  @override
  String get productDescDessert => 'Сладкий десерт';

  @override
  String get productDescDrinksAlt => 'Освежающий напиток';

  @override
  String get productDescDefault =>
      'Премиальные ингредиенты — свежеприготовлено';
}
