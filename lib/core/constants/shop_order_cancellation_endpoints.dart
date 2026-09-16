abstract final class ShopOrderCancellationEndpoints {
  ShopOrderCancellationEndpoints._();

  static const String reasons = '/shop/orders/cancellation-reasons';

  static String cancel(String orderNumber) {
    final String normalizedOrderNumber = orderNumber.trim();

    return '/shop/orders/'
        '${Uri.encodeComponent(normalizedOrderNumber)}'
        '/cancel';
  }
}
