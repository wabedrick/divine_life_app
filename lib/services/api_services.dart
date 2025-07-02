// lib/services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_model.dart';
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

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      // Save token and user info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, data['token'] ?? '');
      await prefs.setString('username', data['username'] ?? '');
      await prefs.setString('email', data['email'] ?? '');
      await prefs.setString('role', data['role'] ?? '');
      await prefs.setInt('mc_id', int.tryParse(data['mc_id'].toString()) ?? 0);
      return data;
    } else {
      // Return error response for UI to handle
      return data;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Admin Management
  static Future<List<Admin>> getAdmins() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}get_admins.php'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Admin.fromJson(json)).toList();
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

  static Future<Admin> createAdmin(Admin admin) async {
    final headers = await _getHeaders();

    // Modify the data to match what PHP expects
    final requestData = {
      'username': admin.username,
      'email': admin.email,
      'mc': admin.mcName, // CHANGE: mc_name to mc
      'password': admin.password,
      'role': admin.role,
    };

    print('Sending admin data: ${jsonEncode(requestData)}'); // Debugging

    final response = await http.post(
      Uri.parse('${baseUrl}register.php'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    print('Response status: ${response.statusCode}'); // Debugging
    print('Response body: ${response.body}'); // Debugging

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      // Handle the success message response from PHP
      if (responseData['status'] == 'success') {
        // Since PHP doesn't return the created admin object, return the original with an assumed ID
        return admin;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create admin');
      }
    } else {
      throw Exception('Failed to create admin: ${response.body}');
    }
  }

  static Future<Admin> updateAdmin(Admin admin) async {
    final headers = await _getHeaders();

    // Use the Admin class's toJson method to ensure consistency
    final body = admin.toJson();

    // Ensure ID is included for update
    if (admin.id != null) {
      body['id'] = admin.id;
    }

    final response = await http.put(
      Uri.parse('${baseUrl}update_admin.php'),
      headers: headers,
      body: jsonEncode(body),
    );

    print(
      'Update Admin Request body: ${jsonEncode(body)}',
    ); // Additional debugging
    print('Response status: ${response.statusCode}'); // Debugging
    print('Response body: ${response.body}'); // Debugging

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Handle success message response
      if (responseData['status'] == 'success') {
        return admin; // Return the original admin if update was successful
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update admin');
      }
    } else {
      // Parse the error message from the PHP response
      try {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ??
            errorResponse['error'] ??
            'Failed to update admin';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Failed to update admin: ${response.body}');
      }
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

  static Future<List<User>> getUsers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}get_users.php'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: \\${response.body}');
    }
  }

  static Future<void> promoteToMCLeader(String userId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}update_user_role.php'),
      body: {'id': userId, 'role': 'mc_leader'},
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to promote user');
    }
  }

  static Future<void> addUser(User user) async {
    final response = await http.post(
      Uri.parse('${baseUrl}add_user.php'),
      body: user.toJson(),
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to add user');
    }
  }

  static Future<void> updateUser(User user) async {
    final response = await http.post(
      Uri.parse('${baseUrl}update_user.php'),
      body: user.toJson(),
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update user');
    }
  }

  static Future<void> deleteUser(String userId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}delete_user.php'),
      body: {'id': userId},
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete user');
    }
  }

  static Future<void> demoteToMember(String userId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}update_user_role.php'),
      body: {'id': userId, 'role': 'member'},
    );
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to demote user');
    }
  }
}
