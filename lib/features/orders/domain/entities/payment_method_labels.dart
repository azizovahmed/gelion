import '../../../../l10n/generated/app_localizations.dart';

String paymentMethodLabel(AppLocalizations l10n, String? code) {
  final c = code?.trim().toLowerCase() ?? '';
  return switch (c) {
    'card' => l10n.orderPaymentCard,
    'online' => l10n.orderPaymentOnline,
    'cash' => l10n.orderPaymentCash,
    _ => l10n.orderPaymentCash,
  };
}
