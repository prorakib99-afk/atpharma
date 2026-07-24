String _pathSegment(Object value) {
  return Uri.encodeComponent(value.toString());
}

// =============================================================================
// Authentication
// =============================================================================

abstract final class AuthEndpoints {
  AuthEndpoints._();

  static const String login = '/auth/login'; // POST
  static const String verifyLoginCode = '/auth/login/verify-code'; // POST
  static const String me = '/auth/me'; // GET
  static const String logout = '/auth/logout'; // POST
}

// =============================================================================
// Users
// =============================================================================

abstract final class UserEndpoints {
  UserEndpoints._();

  static const String completeInvitation = '/users/complete-invitation'; // POST

  static const String users = '/users'; // GET, POST
  static const String me = '/users/me'; // GET
  static const String updateMyProfile = '/users/me/profile'; // PATCH
  static const String changeMyPassword = '/users/me/password'; // PATCH

  static String byId(String id) {
    return '/users/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Roles
// =============================================================================

abstract final class RoleEndpoints {
  RoleEndpoints._();

  static const String roles = '/roles'; // GET, POST

  static String byId(String id) {
    return '/roles/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Permissions
// =============================================================================

abstract final class PermissionEndpoints {
  PermissionEndpoints._();

  static const String modules = '/permissions/modules'; // GET

  static String roleMatrix(String roleId) {
    return '/permissions/roles/${_pathSegment(roleId)}'; // GET, PUT
  }
}

// =============================================================================
// Departments
// =============================================================================

abstract final class DepartmentEndpoints {
  DepartmentEndpoints._();

  static const String departments = '/departments'; // GET, POST

  static String byId(String id) {
    return '/departments/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Sessions
// =============================================================================

abstract final class SessionEndpoints {
  SessionEndpoints._();

  static const String sessions = '/sessions'; // GET, DELETE all

  static String byId(String id) {
    return '/sessions/${_pathSegment(id)}'; // DELETE
  }
}

// =============================================================================
// Suppliers
// =============================================================================

abstract final class SupplierEndpoints {
  SupplierEndpoints._();

  static const String suppliers = '/suppliers'; // GET, POST
  static const String stats = '/suppliers/stats'; // GET

  static String byId(String id) {
    return '/suppliers/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Supplier Categories
// =============================================================================

abstract final class SupplierCategoryEndpoints {
  SupplierCategoryEndpoints._();

  static const String categories = '/supplier-categories'; // GET, POST

  static String byId(String id) {
    return '/supplier-categories/${_pathSegment(id)}'; // PATCH, DELETE
  }
}

// =============================================================================
// Supplier Types
// =============================================================================

abstract final class SupplierTypeEndpoints {
  SupplierTypeEndpoints._();

  static const String types = '/supplier-types'; // GET, POST

  static String byId(String id) {
    return '/supplier-types/${_pathSegment(id)}'; // PATCH, DELETE
  }
}

// =============================================================================
// Supplier Invoices
// =============================================================================

abstract final class SupplierInvoiceEndpoints {
  SupplierInvoiceEndpoints._();

  static const String invoices = '/supplier-invoices'; // GET, POST
  static const String stats = '/supplier-invoices/stats'; // GET
  static const String nextNumber = '/supplier-invoices/next-number'; // GET

  static String byId(String id) {
    return '/supplier-invoices/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }

  static String payments(String id) {
    return '/supplier-invoices/${_pathSegment(id)}/payments'; // POST
  }
}

// =============================================================================
// Products
// =============================================================================

abstract final class ProductEndpoints {
  ProductEndpoints._();

  static const String products = '/products'; // GET, POST
  static const String stats = '/products/stats'; // GET
  static const String expiringSoon = '/products/expiring-soon'; // GET
  static const String genericNames = '/products/generic-names'; // GET
  static const String stockMovement = '/products/stock-movement'; // GET
  static const String expiring = '/products/expiring'; // GET

  static String byId(String id) {
    return '/products/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }

  static String stockAdjustments(String id) {
    return '/products/${_pathSegment(id)}/stock-adjustments'; // GET
  }

  static String batches(String id) {
    return '/products/${_pathSegment(id)}/batches'; // GET, POST
  }

  static String batchById({
    required String productId,
    required String batchId,
  }) {
    return '/products/${_pathSegment(productId)}'
        '/batches/${_pathSegment(batchId)}'; // PATCH, DELETE
  }

  static String adjustStock(String id) {
    return '/products/${_pathSegment(id)}/adjust-stock'; // POST
  }
}

// =============================================================================
// Product Categories
// =============================================================================

abstract final class ProductCategoryEndpoints {
  ProductCategoryEndpoints._();

  static const String categories = '/product-categories'; // GET, POST

  static String byId(String id) {
    return '/product-categories/${_pathSegment(id)}'; // PATCH, DELETE
  }
}

// =============================================================================
// Product Types
// =============================================================================

abstract final class ProductTypeEndpoints {
  ProductTypeEndpoints._();

  static const String types = '/product-types'; // GET, POST

  static String byId(String id) {
    return '/product-types/${_pathSegment(id)}'; // PATCH, DELETE
  }
}

// =============================================================================
// Customers
// =============================================================================

abstract final class CustomerEndpoints {
  CustomerEndpoints._();

  static const String customers = '/customers'; // GET, POST
  static const String stats = '/customers/stats'; // GET

  static String byId(String id) {
    return '/customers/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Admin Orders
// =============================================================================

abstract final class OrderEndpoints {
  OrderEndpoints._();

  static const String orders = '/orders'; // GET, POST
  static const String stats = '/orders/stats'; // GET

  static String byId(String id) {
    return '/orders/${_pathSegment(id)}'; // GET, DELETE
  }

  static String updateStatus(String id) {
    return '/orders/${_pathSegment(id)}/status'; // PATCH
  }

  static String updatePayment(String id) {
    return '/orders/${_pathSegment(id)}/payment'; // PATCH
  }
}

// =============================================================================
// Public Storefront Orders
// =============================================================================

abstract final class ShopOrderEndpoints {
  ShopOrderEndpoints._();

  static const String config = '/shop/orders/config'; // GET
  static const String createOrder = '/shop/orders'; // POST

  static String pay(String orderNumber) {
    return '/shop/orders/${_pathSegment(orderNumber)}/pay'; // POST
  }

  static String reconcile(String orderNumber) {
    return '/shop/orders/${_pathSegment(orderNumber)}/reconcile'; // POST
  }

  static String paymentIntent(String orderNumber) {
    return '/shop/orders/'
        '${_pathSegment(orderNumber)}/payment-intent'; // POST
  }

  static String confirmIntent(String orderNumber) {
    return '/shop/orders/'
        '${_pathSegment(orderNumber)}/confirm-intent'; // POST
  }

  static String byOrderNumber(String orderNumber) {
    return '/shop/orders/${_pathSegment(orderNumber)}'; // GET
  }
}

// =============================================================================
// Public Shop Catalog
// =============================================================================

abstract final class ShopCatalogEndpoints {
  ShopCatalogEndpoints._();

  static const String products = '/shop/products'; // GET
  static const String productCount = '/shop/products/count'; // GET
  static const String categories = '/shop/categories'; // GET

  static String productByIdOrSlug(String idOrSlug) {
    return '/shop/products/${_pathSegment(idOrSlug)}'; // GET
  }
}

// =============================================================================
// Coupons
// =============================================================================

abstract final class CouponEndpoints {
  CouponEndpoints._();

  static const String coupons = '/coupons'; // GET, POST
  static const String stats = '/coupons/stats'; // GET

  /// Public coupon validation endpoint.
  static const String validate = '/shop/coupons/validate'; // POST

  static String byId(String id) {
    return '/coupons/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Offers
// =============================================================================

abstract final class OfferEndpoints {
  OfferEndpoints._();

  static const String offers = '/offers'; // GET, POST
  static const String stats = '/offers/stats'; // GET

  /// Public active offers endpoint.
  static const String shopOffers = '/shop/offers'; // GET

  static String byId(String id) {
    return '/offers/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Payment Methods
// =============================================================================

abstract final class PaymentMethodEndpoints {
  PaymentMethodEndpoints._();

  static const String methods = '/payment-methods'; // GET, POST
  static const String reorder = '/payment-methods/reorder'; // PATCH
  static const String test = '/payment-methods/test'; // POST

  /// Public checkout payment methods.
  static const String shopMethods = '/shop/payment-methods'; // GET

  static String byId(String id) {
    return '/payment-methods/${_pathSegment(id)}'; // GET, PATCH, DELETE
  }
}

// =============================================================================
// Payment Transactions
// =============================================================================

abstract final class PaymentTransactionEndpoints {
  PaymentTransactionEndpoints._();

  static const String transactions = '/payment-transactions'; // GET, POST

  static const String stats = '/payment-transactions/stats'; // GET

  static String byId(String id) {
    return '/payment-transactions/${_pathSegment(id)}'; // GET
  }

  static String updateStatus(String id) {
    return '/payment-transactions/${_pathSegment(id)}/status'; // PATCH
  }

  static String refund(String id) {
    return '/payment-transactions/${_pathSegment(id)}/refund'; // POST
  }
}

// =============================================================================
// Billing Settings
// =============================================================================

abstract final class BillingSettingsEndpoints {
  BillingSettingsEndpoints._();

  static const String settings = '/billing-settings'; // GET, PATCH
}

// =============================================================================
// Delivery
// =============================================================================

abstract final class DeliveryEndpoints {
  DeliveryEndpoints._();

  static const String deliveries = '/delivery'; // GET
  static const String stats = '/delivery/stats'; // GET
  static const String riders = '/delivery/riders'; // GET, POST

  static String riderById(String id) {
    return '/delivery/riders/${_pathSegment(id)}'; // PATCH, DELETE
  }

  static String byId(String id) {
    return '/delivery/${_pathSegment(id)}'; // GET
  }

  static String assignRider(String id) {
    return '/delivery/${_pathSegment(id)}/assign'; // PATCH
  }

  static String updateStatus(String id) {
    return '/delivery/${_pathSegment(id)}/status'; // PATCH
  }

  static String updateCharge(String id) {
    return '/delivery/${_pathSegment(id)}/charge'; // PATCH
  }

  /// Public tracking endpoint.
  static String track(String code) {
    return '/track/${_pathSegment(code)}'; // GET
  }
}

// =============================================================================
// Dashboard
// =============================================================================

abstract final class DashboardEndpoints {
  DashboardEndpoints._();

  static const String overview = '/dashboard/overview'; // GET
  static const String reports = '/dashboard/reports'; // GET
}

// =============================================================================
// User Settings
// =============================================================================

abstract final class SettingsEndpoints {
  SettingsEndpoints._();

  static const String settings = '/settings'; // GET, PATCH
  static const String security = '/settings/security'; // PATCH
  static const String reset = '/settings/reset'; // POST
}

// =============================================================================
// Theme
// =============================================================================

abstract final class ThemeEndpoints {
  ThemeEndpoints._();

  /// Public theme options.
  static const String options = '/theme/options'; // GET
}

// =============================================================================
// Notifications
// =============================================================================

abstract final class NotificationEndpoints {
  NotificationEndpoints._();

  static const String notifications = '/notifications'; // GET
  static const String unreadCount = '/notifications/unread-count'; // GET

  static const String readAll = '/notifications/read-all'; // PATCH

  static String read(String id) {
    return '/notifications/${_pathSegment(id)}/read'; // PATCH
  }
}

// =============================================================================
// Activity Logs
// =============================================================================

abstract final class ActivityLogEndpoints {
  ActivityLogEndpoints._();

  static const String logs = '/activity-logs'; // GET
}
