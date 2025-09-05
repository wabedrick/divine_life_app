// ignore_for_file: avoid_print

import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import '../models/mc_model.dart';

class MissionalCommunityService {
  // Base URL for API endpoints
  static const String baseUrl = 'http://127.0.0.1:8000/missionalCommunity';
  // Static header for API requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Create a new Missional Community
  static Future<Map<String, dynamic>> createMC(MissionalCommunity mc) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_mc.php'),
        headers: headers,
        body: jsonEncode(mc.toJson()),
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating MC: $e',
      };
    }
  }

  // Get all Missional Communities
  static Future<List<MissionalCommunity>> getAllMCs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fetch_mcs.php'),
        headers: headers,
      );
      print('Response body: ${response.body}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> mcList = responseData['mcs'];
        return mcList
            .map((json) => MissionalCommunity.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API reported failure: ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Error getting MCs: $e');
    }
  }

  // Get a single Missional Community by ID
  static Future<MissionalCommunity> getMC(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_mc.php?id=$id'),
        headers: headers,
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return MissionalCommunity.fromJson(responseData['mc']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get MC');
      }
    } catch (e) {
      throw Exception('Error getting MC: $e');
    }
  }

  // Update an existing Missional Community
  static Future<Map<String, dynamic>> updateMC(MissionalCommunity mc) async {
    if (mc.id == null) {
      return {
        'success': false,
        'message': 'Cannot update MC without ID',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_mc.php'),
        headers: headers,
        body: jsonEncode(mc.toJson()..['id'] = mc.id),
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating MC: $e',
      };
    }
  }

  // Delete a Missional Community
  static Future<bool> deleteMC(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_mc.php'),
        headers: headers,
        body: jsonEncode({'id': id}),
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return true;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete MC');
      }
    } catch (e) {
      throw Exception('Error deleting MC: $e');
    }
  }
}
