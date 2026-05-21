import '../../../menu/domain/home_product.dart';
import '../../../../l10n/generated/app_localizations.dart';

String resolveProductDescription(HomeProduct p, AppLocalizations l10n) {
  final ing = p.ingredients?.trim();
  if (ing != null && ing.isNotEmpty) return ing;
  final d = p.description?.trim();
  if (d != null && d.isNotEmpty) return d;
  return l10n.productDescDefault;
}
