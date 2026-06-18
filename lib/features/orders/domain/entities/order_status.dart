import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import 'order_status_codec.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  delivering,
  completed,
  cancelled;

  static OrderStatus fromCode(String? raw) {
    final code = _normalizeCode(raw);
    if (code.isEmpty) return OrderStatus.pending;

    const aliases = <String, OrderStatus>{
      'pending': OrderStatus.pending,
      'new': OrderStatus.pending,
      'waiting': OrderStatus.pending,
      'kutilmoqda': OrderStatus.pending,
      'accepted': OrderStatus.accepted,
      'qabul_qilindi': OrderStatus.accepted,
      'qabul': OrderStatus.accepted,
      'confirmed': OrderStatus.accepted,
      'preparing': OrderStatus.preparing,
      'preparation': OrderStatus.preparing,
      'in_progress': OrderStatus.preparing,
      'processing': OrderStatus.preparing,
      'cooking': OrderStatus.preparing,
      'ready': OrderStatus.preparing,
      'tayyorlanmoqda': OrderStatus.preparing,
      'delivering': OrderStatus.delivering,
      'delivery': OrderStatus.delivering,
      'on_the_way': OrderStatus.delivering,
      'in_delivery': OrderStatus.delivering,
      'shipped': OrderStatus.delivering,
      'yetkazilmoqda': OrderStatus.delivering,
      'completed': OrderStatus.completed,
      'complete': OrderStatus.completed,
      'delivered': OrderStatus.completed,
      'done': OrderStatus.completed,
      'finished': OrderStatus.completed,
      'success': OrderStatus.completed,
      'yakunlandi': OrderStatus.completed,
      'yetkazildi': OrderStatus.completed,
      'cancelled': OrderStatus.cancelled,
      'canceled': OrderStatus.cancelled,
      'rejected': OrderStatus.cancelled,
      'bekor': OrderStatus.cancelled,
      'bekor_qilindi': OrderStatus.cancelled,
    };

    final mapped = aliases[code];
    if (mapped != null) return mapped;

    return OrderStatus.values.firstWhere(
      (s) => s.name == code,
      orElse: () => OrderStatus.pending,
    );
  }

  static String _normalizeCode(String? raw) {
    return (raw ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-]+'), '_');
  }

  String get code => name;

  String get firestoreValue => OrderStatusCodec.toFirestore(this);

  bool get isTerminal =>
      this == OrderStatus.completed || this == OrderStatus.cancelled;

  static const List<OrderStatus> timelineFlow = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.delivering,
    OrderStatus.completed,
  ];

  int get timelineIndex => timelineFlow.indexOf(this);

  IconData get icon {
    return switch (this) {
      OrderStatus.pending => Icons.schedule_rounded,
      OrderStatus.accepted => Icons.thumb_up_alt_rounded,
      OrderStatus.preparing => Icons.restaurant_rounded,
      OrderStatus.delivering => Icons.delivery_dining_rounded,
      OrderStatus.completed => Icons.check_circle_rounded,
      OrderStatus.cancelled => Icons.cancel_rounded,
    };
  }

  Color get color {
    return switch (this) {
      OrderStatus.pending => const Color(0xFFFFC107),
      OrderStatus.accepted => const Color(0xFF42A5F5),
      OrderStatus.preparing => const Color(0xFF42A5F5),
      OrderStatus.delivering => const Color(0xFFE65100),
      OrderStatus.completed => const Color(0xFF66BB6A),
      OrderStatus.cancelled => const Color(0xFFEF5350),
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      OrderStatus.pending => l10n.orderStatusPending,
      OrderStatus.accepted => l10n.orderStatusAccepted,
      OrderStatus.preparing => l10n.orderStatusPreparing,
      OrderStatus.delivering => l10n.orderStatusDelivering,
      OrderStatus.completed => l10n.orderStatusCompleted,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
    };
  }
}
