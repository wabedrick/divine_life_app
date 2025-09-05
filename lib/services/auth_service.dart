// services/auth_service.dart
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../services/missional_community_service.dart';
import 'api_services.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Attempts to login and returns a User object if successful
  Future<User?> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/login');
      final response = await http
          .post(url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'username': username, 'password': password}))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        // support both legacy and new shapes
        final token = data['token'] ?? data['access_token'] ?? data['plainTextToken'] ?? '';
        final userObj = data['user'] ?? data;
        if (token == null || (token is String && token.isEmpty)) {
          throw AuthException(data['message'] ?? 'Login failed');
        }

        // persist token securely
        await _secureStorage.write(key: _tokenKey, value: token.toString());

        // save user info in prefs
        final prefs = await SharedPreferences.getInstance();
        final usernameSaved = userObj['username'] ?? userObj['name'] ?? username;
        await prefs.setString(_userKey, json.encode({
          'username': usernameSaved,
          'email': userObj['email'] ?? '',
          'mc': userObj['mc_id']?.toString() ?? userObj['missional_community'] ?? '',
          'id': userObj['id']?.toString() ?? '',
        }));

        // store display name
        if (userObj['name'] != null && userObj['name'].toString().isNotEmpty) {
          await prefs.setString('user_name', userObj['name']);
        } else {
          await prefs.setString('user_name', usernameSaved);
        }

        // fetch and store roles
        final idStr = userObj['id']?.toString();
        if (idStr != null && idStr.isNotEmpty) {
          await _fetchAndStoreRoles(idStr);
        }

        return User(
          username: usernameSaved ?? '',
          email: userObj['email'] ?? '',
          role: prefs.getString('role') ?? '',
          userPassword: '',
          missionalCommunity: userObj['mc_id']?.toString() ?? '',
          id: idStr ?? '',
        );
      } else {
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
  final token = await _secureStorage.read(key: _tokenKey);
  if (token != null) return token;
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
      await _secureStorage.delete(key: _tokenKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      throw AuthException('Failed to logout: ${e.toString()}');
    }
  }

  Future<void> _fetchAndStoreRoles(String userId) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return;
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/$userId/roles'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final roles = (data['roles'] as List?)?.map((r) => r['name']?.toString() ?? '').where((s) => s.isNotEmpty).join(',') ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', roles);
      }
    } catch (_) {
      // non-fatal
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
