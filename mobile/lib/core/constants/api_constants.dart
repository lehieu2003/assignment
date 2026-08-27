class ApiConstants {
  // For Android emulator: http://10.0.2.2:8000/api/v1
  // For iOS simulator: http://localhost:8000/api/v1
  // For Real devices: http://<YOUR_LOCAL_IP>:8000/api/v1
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  static const String health = '/health/';
  static const String register = '/auth/register';
  static const String login = '/auth/login/access-token';
  static const String me = '/auth/me';
  static const String todos = '/todos/';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
