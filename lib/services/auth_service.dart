// services/auth_service.dart
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  /// Attempts to login and returns a User object if successful
  Future<User?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}/users/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      // Check for HTTP errors
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException('Server error: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        // Ensure data contains user information
        if (data['user'] == null) {
          throw AuthException('Invalid server response: missing user data');
        }

        // Create user object
        final User user = User.fromJson(data['user']);

        // Save user session data
        await _saveUserSession(user, data['token'] ?? '');

        return user;
      } else {
        // Handle known error responses
        throw AuthException(data['message'] ?? 'Login failed');
      }
    } on http.ClientException catch (_) {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException catch (_) {
      throw AuthException('Invalid server response');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Save user session data locally
  Future<void> _saveUserSession(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      throw AuthException('Failed to save session: ${e.toString()}');
    }
  }

  /// Get current logged in user (null if not logged in)
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData == null) {
        return null;
      }

      return User.fromJson(json.decode(userData));
    } catch (e) {
      return null;
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    final token = await getToken();
    return user != null && token != null;
  }

  /// Logout user by clearing stored session data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      throw AuthException('Failed to logout: ${e.toString()}');
    }
  }

  /// Request password reset email
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}/users/reset_password.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException('Server error: ${response.statusCode}');
      }

      // Handle response if needed
    } catch (e) {
      throw AuthException('Failed to request password reset: ${e.toString()}');
    }
  }
}
