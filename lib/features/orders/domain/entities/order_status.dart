import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

enum OrderStatus {
  pending,
  preparing,
  delivering,
  completed,
  cancelled;

  static OrderStatus fromCode(String? raw) {
    final code = raw?.trim().toLowerCase() ?? '';
    return OrderStatus.values.firstWhere(
      (s) => s.name == code,
      orElse: () => OrderStatus.pending,
    );
  }

  String get code => name;

  bool get isTerminal => this == OrderStatus.completed || this == OrderStatus.cancelled;

  /// Normal delivery flow steps (excludes cancelled).
  static const List<OrderStatus> timelineFlow = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.delivering,
    OrderStatus.completed,
  ];

  int get timelineIndex => timelineFlow.indexOf(this);

  IconData get icon {
    return switch (this) {
      OrderStatus.pending => Icons.schedule_rounded,
      OrderStatus.preparing => Icons.restaurant_rounded,
      OrderStatus.delivering => Icons.delivery_dining_rounded,
      OrderStatus.completed => Icons.check_circle_rounded,
      OrderStatus.cancelled => Icons.cancel_rounded,
    };
  }

  Color get color {
    return switch (this) {
      OrderStatus.pending => const Color(0xFFFF8C00),
      OrderStatus.preparing => const Color(0xFF42A5F5),
      OrderStatus.delivering => const Color(0xFFAB47BC),
      OrderStatus.completed => const Color(0xFF66BB6A),
      OrderStatus.cancelled => const Color(0xFFEF5350),
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      OrderStatus.pending => l10n.orderStatusPending,
      OrderStatus.preparing => l10n.orderStatusPreparing,
      OrderStatus.delivering => l10n.orderStatusDelivering,
      OrderStatus.completed => l10n.orderStatusCompleted,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
    };
  }
}
