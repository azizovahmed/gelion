import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [app_locale] and mirrors legacy [profile_selected_language] for migration.
class LocaleController extends ChangeNotifier {
  LocaleController();

  static const prefKey = 'app_locale';
  static const legacyProfileLangKey = 'profile_selected_language';

  Locale _locale = const Locale('uz');
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    var code = prefs.getString(prefKey);
    if (code == null || code.isEmpty) {
      final legacy = prefs.getString(legacyProfileLangKey);
      code = switch (legacy) {
        'RU' => 'ru',
        'EN' => 'en',
        _ => 'uz',
      };
    }
    _locale = Locale(_normalize(code));
    notifyListeners();
  }

  String _normalize(String code) {
    final c = code.toLowerCase();
    if (c.startsWith('ru')) return 'ru';
    if (c.startsWith('en')) return 'en';
    return 'uz';
  }

  Future<void> setLocale(Locale locale) async {
    final c = _normalize(locale.languageCode);
    final next = Locale(c);
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, c);
    await prefs.setString(
      legacyProfileLangKey,
      switch (c) {
        'ru' => 'RU',
        'en' => 'EN',
        _ => 'UZ',
      },
    );
  }
}
