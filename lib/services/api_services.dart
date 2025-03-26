// lib/services/api_service.dart
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl =
      'https://divinelifeministriesinternational.org/users/'; // Replace with your API URL
  static const String tokenKey = 'auth_token';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, data['token']);

      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Admin Management
  static Future<List<User>> getAdmins() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}get_admins.php'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load admins: ${response.body}');
    }
  }

  static Future<User> getAdmin(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load admin: ${response.body}');
    }
  }

  static Future<User> createAdmin(User admin) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}register.php'),
      headers: headers,
      body: jsonEncode(admin.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create admin: ${response.body}');
    }
  }

  static Future<User> updateAdmin(User admin) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${baseUrl}update_admin.php'),
      headers: headers,
      body: jsonEncode(
        <String, dynamic>{
          // 'id': admin.id,
          'username': admin.username,
          'email': admin.email,
          'role': admin.role,
          'password': admin.password,
        }..removeWhere((_, value) => value == null),
      ),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update admin: ${response.body}');
    }
  }

  // static Future<bool> deleteAdmin(int id) async {
  //   final headers = await _getHeaders();
  //   final response = await http.delete(
  //     Uri.parse('${baseUrl}delete_user.php/$id'),
  //     headers: headers,
  //   );

  //   if (response.statusCode == 204) {
  //     return true;
  //   } else {
  //     throw Exception('Failed to delete admin: ${response.body}');
  //   }
  // }

  static Future<void> deleteAdmin(int id) async {
    final response = await http.post(
      Uri.parse('${baseUrl}delete_user.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'id': id}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete Admin');
    }
  }
}
