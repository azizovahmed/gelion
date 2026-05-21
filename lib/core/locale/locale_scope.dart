import 'package:flutter/material.dart';

import 'locale_controller.dart';

/// Provides [LocaleController] below [MaterialApp] so UI can change language without restart.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController super.notifier,
    required super.child,
  });

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope?.notifier != null, 'LocaleScope not found above this context');
    return scope!.notifier!;
  }
}
