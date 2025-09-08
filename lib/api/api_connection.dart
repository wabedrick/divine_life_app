import 'dart:io';

class API {
  // Choose correct host for Android emulator vs other platforms.
  // - Android emulator (AVD) must use 10.0.2.2 to reach host machine's localhost
  // - Physical device should use the machine's LAN IP (replace at runtime or via config)
  static String get _baseURL {
    if (Platform.isAndroid) {
      // For physical Android devices running on the same LAN, use the host PC LAN IP.
      // Change this value if your PC IP changes. Emulators use 10.0.2.2, but here
      // we're targeting a physical device so we prefer the LAN address.
      return 'http://192.168.42.92:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  // User-related endpoints
  static String get _userEndpoint => '$_baseURL/users';

  // Public helper for other code to reference the Laravel API base (includes /api)
  static String get laravelApi => '$_baseURL/api';

  // Signup endpoint
  // Signup endpoint -> Laravel API /api/register
  static Uri get signup => Uri.parse('$laravelApi/register');

  // Check email endpoint (Laravel convention may vary)
  static Uri get checkEmail => Uri.parse('$laravelApi/check_email');

  // Login endpoint -> Laravel API /api/login
  static Uri get login => Uri.parse('$laravelApi/login');
}
