/// Central API endpoint paths (base URL is in ApiService).
/// Use with: ApiService().dio.get(ApiEndpoints.appointmentsToday)
class ApiEndpoints {
  ApiEndpoints._();

  // ----- Auth (used by AuthService) -----
  static const String login = '/login/access-token';
  static const String users = '/users/';

  // ----- Appointments -----
  static const String appointments = '/appointments/';
  static String appointmentById(String id) => '/appointments/$id';
  static const String appointmentsToday = '/appointments/today';
  static const String appointmentsUpcoming = '/appointments/upcoming';
  static const String appointmentsAlerts = '/appointments/alerts';

  // ----- Doctors -----
  static const String doctors = '/doctors/';
  static const String doctorsFeatured = '/doctors/featured';
  static String doctorById(String id) => '/doctors/$id';
  static String doctorSlots(String doctorId) => '/doctors/$doctorId/slots';

  // ----- Specialties -----
  static const String specialties = '/specialties/';

  // ----- User profile & location -----
  static const String usersMe = '/users/me';
  static const String usersMeLocation = '/users/me/location';
  static const String usersMeAppointmentsHistory = '/users/me/appointments/history';
  static const String usersMePayments = '/users/me/payments';

  // ----- Cart -----
  static const String cart = '/cart/';
  static const String cartSummary = '/cart/summary';
  static const String cartItems = '/cart/items';
  static String cartItemById(String id) => '/cart/items/$id';

  // ----- Pharmacy -----
  static const String pharmacyCategories = '/pharmacy/categories';
  static String pharmacyCategoryProducts(String categoryId) =>
      '/pharmacy/categories/$categoryId/products';
  static const String pharmacyNearby = '/pharmacy/nearby';
  static const String pharmacyOrders = '/pharmacy/orders';
  static const String pharmacyProducts = '/pharmacy/products';

  // ----- Messages -----
  static const String messagesConversations = '/messages/conversations';
  static String messagesConversationById(String id) =>
      '/messages/conversations/$id';

  // ----- AI Checkup -----
  static const String aiCheckupConditions = '/ai-checkup/conditions';
  static const String aiCheckupAssessments = '/ai-checkup/assessments';
  static String aiCheckupAssessmentById(String id) =>
      '/ai-checkup/assessments/$id';
}
