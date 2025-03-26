import '../models/mc_model.dart';
import '../models/weekly_report_model.dart';
import '../models/report_summary_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class McServices {
  static const String baseUrl =
      'https://divinelifeministriesinternational.org/missionalCommunities/'; // Replace with your API URL
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

  static Future<List<MissionalCommunity>> getMicroCommunities() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/micro-communities'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MissionalCommunity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load micro communities: ${response.body}');
    }
  }

  static Future<MissionalCommunity> getMissionalCommunity(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/missional-communities/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return MissionalCommunity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load missional community: ${response.body}');
    }
  }

  static Future<MissionalCommunity> createMissionalCommunity(
    MissionalCommunity mc,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/missional-communities'),
      headers: headers,
      body: jsonEncode(mc.toJson()),
    );

    if (response.statusCode == 201) {
      return MissionalCommunity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create missional community: ${response.body}');
    }
  }

  static Future<MissionalCommunity> updateMissionalCommunity(
    MissionalCommunity mc,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/missional-communities/${mc.id}'),
      headers: headers,
      body: jsonEncode(mc.toJson()),
    );

    if (response.statusCode == 200) {
      return MissionalCommunity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update missional community: ${response.body}');
    }
  }

  static Future<bool> deleteMissionalCommunity(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/missional-communities/$id'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete missional community: ${response.body}');
    }
  }

  // Weekly Reports
  static Future<List<WeeklyReport>> getWeeklyReports({
    int? mcId,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders();

    // Build query parameters
    final queryParams = <String, String>{};
    if (mcId != null) queryParams['mc_id'] = mcId.toString();
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final uri = Uri.parse(
      '$baseUrl/weekly-reports',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WeeklyReport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load weekly reports: ${response.body}');
    }
  }

  static Future<WeeklyReport> getWeeklyReport(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weekly-reports/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return WeeklyReport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weekly report: ${response.body}');
    }
  }

  static Future<List<WeeklyReport>> getRecentReports({int limit = 5}) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weekly-reports/recent?limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WeeklyReport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recent reports: ${response.body}');
    }
  }

  static Future<ReportSummary> getReportSummary({
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders();

    // Build query parameters
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final uri = Uri.parse(
      '$baseUrl/reports/summary',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return ReportSummary.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load report summary: ${response.body}');
    }
  }
}
