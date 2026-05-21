import 'package:flutter_test/flutter_test.dart';
import 'package:gelion_app/core/utils/validators.dart';
import 'package:gelion_app/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('email validator works', () {
    expect(Validators.email(l10n, ''), isNotNull);
    expect(Validators.email(l10n, 'test@example.com'), isNull);
  });
}
