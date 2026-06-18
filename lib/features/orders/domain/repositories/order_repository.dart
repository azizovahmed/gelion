import '../../../cart/domain/entities/cart_line.dart';
import '../entities/app_order.dart';

abstract class OrderRepository {
  Stream<List<AppOrder>> watchAllOrders();

  Stream<List<AppOrder>> watchUserOrders(
    String userId, {
    int limit = 20,
  });

  Stream<AppOrder?> watchUserOrder(String userId, String orderId);

  Future<String?> placeOrder({
    required String userId,
    required String customerName,
    required String phone,
    String customerEmail = '',
    required List<CartLine> lines,
    required int subtotal,
    required int deliveryPrice,
    required int discount,
    required int totalPrice,
    required String address,
    String paymentMethod = 'cash',
  });

  Future<void> updateOrderStatus({
    required String userId,
    required String orderId,
    required String status,
  });
}
