import '../../l10n/generated/app_localizations.dart';

class Validators {
  static String? requiredField(AppLocalizations l10n, String? value, String label) {
    if (value == null || value.trim().isEmpty) return l10n.validationEnterField(label);
    return null;
  }

  static String? email(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.validationEnterEmail;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return l10n.validationEmailInvalid;
    return null;
  }

  static String? password(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.validationEnterPassword;
    if (value.trim().length < 6) return l10n.validationPasswordShort;
    return null;
  }

  /// Kamida 6 belgi + katta/kichik harf, raqam va maxsus belgi.
  static String? strongPassword(AppLocalizations l10n, String? value) {
    final base = password(l10n, value);
    if (base != null) return base;
    final v = value!.trim();
    if (!RegExp('[A-Z]').hasMatch(v)) return l10n.validationPasswordNeedUpper;
    if (!RegExp('[a-z]').hasMatch(v)) return l10n.validationPasswordNeedLower;
    if (!RegExp(r'\d').hasMatch(v)) return l10n.validationPasswordNeedDigit;
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(v)) return l10n.validationPasswordNeedSpecial;
    return null;
  }

  static String? phone(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.validationEnterPhone;
    final raw = value.replaceAll(RegExp(r'\s'), '');
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.length < 9) return l10n.validationPhoneInvalid;
    return null;
  }

  static String? confirmPassword(AppLocalizations l10n, String? password, String? confirm) {
    final p = password?.trim() ?? '';
    final c = confirm?.trim() ?? '';
    if (p != c) return l10n.validationPasswordMismatch;
    return null;
  }

  static String? feedbackMessage(AppLocalizations l10n, String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return l10n.feedbackValidationEmpty;
    if (t.length < 10) return l10n.feedbackValidationMin10;
    return null;
  }
}
