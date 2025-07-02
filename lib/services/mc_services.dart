import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weekly_report_model.dart';

class McServices {
  static const String _reportsFetchUrl = 'https://divinelifeministriesinternational.org/missionalCommunity/weekly_reports_fetch.php';

  static Future<List<WeeklyReport>> fetchAllReports({String? startDate, String? endDate, String? mcName}) async {
    final params = <String, String>{};
    if (startDate != null && endDate != null) {
      params['startDate'] = startDate;
      params['endDate'] = endDate;
    }
    if (mcName != null && mcName.isNotEmpty) {
      params['mcName'] = mcName;
    }
    final uri = Uri.parse('https://divinelifeministriesinternational.org/missionalCommunity/weekly_reports_fetch.php')
      .replace(queryParameters: params);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return (data['reports'] as List)
          .map((json) => WeeklyReport.fromJson(json))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch reports');
    }
  }

  // Mock/test data for WeeklyReport (using only new fields)
  static Future<List<WeeklyReport>> getRecentReports() async {
    return Future.delayed(
      Duration(seconds: 1),
      () => [
        WeeklyReport(
          id: 1,
          meetingDate: '2024-06-01',
          mcName: 'MC 1',
          attendance: 20,
          newMember: 2,
          meetUp: 'Yes',
          giving: 150.0,
          leaderName: 'John Doe',
          comment: 'Great meeting!',
        ),
        WeeklyReport(
          id: 2,
          meetingDate: '2024-06-08',
          mcName: 'MC 2',
          attendance: 18,
          newMember: 1,
          meetUp: 'No',
          giving: 120.0,
          leaderName: 'Jane Smith',
          comment: 'Challenging week, but good turnout.',
        ),
      ],
    );
  }

  static Future<List<WeeklyReport>> getWeeklyReports({
    int? mcId,
    String? startDate,
    String? endDate,
  }) async {
    return Future.delayed(
      Duration(seconds: 1),
      () => [
        WeeklyReport(
          id: 3,
          meetingDate: '2024-06-15',
          mcName: 'Sample MC',
          attendance: 15,
          newMember: 0,
          meetUp: 'Yes',
          giving: 100.0,
          leaderName: 'Sample Leader',
          comment: 'Sample comment for the week.',
        ),
      ],
    );
  }

  // Auth helpers (if needed)
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://yourdomain.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      final responseData = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', responseData['token']);
      await prefs.setString('user_id', responseData['user_id'].toString());
      await prefs.setString('user_name', responseData['name'] ?? '');
      await prefs.setBool('is_admin', responseData['is_admin'] == 1);
      return true;
    } catch (e) {
      throw Exception('Login failed: e');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('is_admin');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  static Future<Map<String, dynamic>> fetchWeeklySummary({String? startDate, String? endDate}) async {
    final uri = Uri.parse('https://divinelifeministriesinternational.org/missionalCommunity/weekly_summary.php')
      .replace(queryParameters: {
        if (startDate != null && endDate != null) ...{
          'startDate': startDate,
          'endDate': endDate,
        }
      });
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch summary');
    }
  }

  // Stub for MC stats filtered by MC name
  static Future<Map<String, dynamic>> getMCStats({String? mcName}) async {
    // Implement backend endpoint to support this if needed
    return {};
  }
}
