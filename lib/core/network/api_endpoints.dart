class ApiEndpoints {
  // Central Base URL Configuration
  // 1. Android Emulator: 'https://api.mytalabaty.com/api'
  // 2. Physical Device / LAN: Change to your machine's LAN IP (e.g., 'http://192.168.1.100:3000/api')
  // 3. Production: 'https://api.talabaty.com/api'
  static const String baseUrl = 'https://api.mytalabaty.com/api';

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String registerCustomer = '/auth/register/customer';
  static const String registerMerchant = '/auth/register/merchant';
  static const String registerCourier = '/auth/register/courier';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
}
