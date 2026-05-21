import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_l10n.dart';

/// Tashqi brauzerda HTTPS havolani ochish: [canLaunchUrl] → [launchUrl].
abstract final class LegalUrlLauncher {
  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  /// [urlString] — to‘liq `https://...` manzil. Bo‘sh yoki noto‘g‘ri bo‘lsa Snackbar.
  static Future<void> openHttpsExternal(BuildContext context, String urlString) async {
    final l10n = context.l10n;
    final err = l10n.settingsCouldNotOpenLink;

    final trimmed = urlString.trim();
    if (trimmed.isEmpty) {
      _showError(context, err);
      return;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) {
      _showError(context, err);
      return;
    }

    try {
      final can = await canLaunchUrl(uri);
      if (!can) {
        if (context.mounted) _showError(context, err);
        return;
      }

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: kIsWeb ? '_blank' : null,
      );
      if (!opened && context.mounted) {
        _showError(context, err);
      }
    } catch (_) {
      if (context.mounted) _showError(context, err);
    }
  }
}
