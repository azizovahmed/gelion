import 'package:flutter/material.dart';

import '../../../../core/locale/locale_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'main_shell_page.dart';

/// Asosiy ilova sahifasi (splashdan keyin kirish nuqtasi).
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authRepository,
    required this.onThemeChanged,
    required this.localeController,
  });

  final AuthRepository authRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return MainShellPage(
      authRepository: authRepository,
      onThemeChanged: onThemeChanged,
      localeController: localeController,
    );
  }
}
