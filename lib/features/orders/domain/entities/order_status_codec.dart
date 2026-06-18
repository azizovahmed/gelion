import 'order_status.dart';

/// Firestore `status` maydoni — o‘zbekcha matn.
class OrderStatusCodec {
  OrderStatusCodec._();

  static const String defaultStatus = 'Kutilmoqda';

  static String toFirestore(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'Kutilmoqda',
      OrderStatus.accepted => 'Qabul qilindi',
      OrderStatus.preparing => 'Tayyorlanmoqda',
      OrderStatus.delivering => 'Yetkazilmoqda',
      OrderStatus.completed => 'Yetkazildi',
      OrderStatus.cancelled => 'Bekor qilindi',
    };
  }

  /// Admin dropdown / kod → Firestore.
  static String toFirestoreFromCode(String code) =>
      toFirestore(OrderStatus.fromCode(code));
}
