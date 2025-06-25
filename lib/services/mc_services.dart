import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_summary_model.dart';
import '../models/weekly_report_model.dart';

class McServices {
  // Base URL for the API
  static const String _baseUrl = 'https://yourdomain.com/api';

  // Endpoints
  static const String _reportsEndpoint = '/reports';
  static const String _loginEndpoint = '/login';
  static const String _statsEndpoint = '/stats';

  // Get auth token from shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get user ID from shared preferences
  static Future<String?> get currentUserId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Standard headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Handle errors from HTTP responses
  static _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Unknown error occurred');
    }
  }

  // Get reports for the current leader
  static Future<List<WeeklyReport>> getLeaderReports() async {
    final userId = await currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_reportsEndpoint?user_id=$userId'),
        headers: headers,
      );

      _handleError(response);

      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) {
        // Convert dates from string to DateTime
        return WeeklyReport(
          id: data['id'].toString(),
          mcName: data['mc_name'] ?? '',
          leaderName: data['leader_name'] ?? '',
          location: data['location'] ?? '',
          weekStarting: DateTime.parse(data['week_starting']),
          meetingDate: DateTime.parse(data['meeting_date']),
          submissionDate: DateTime.parse(data['submission_date']),
          submittedBy: data['submitted_by'] ?? '',
          approved: data['approved'] == 1,
          adultCount: data['adult_count'] ?? 0,
          childrenCount: data['children_count'] ?? 0,
          visitorCount: data['visitor_count'] ?? 0,
          devotionalTopic: data['devotional_topic'] ?? '',
          prayerRequests: data['prayer_requests'] ?? '',
          testimony: data['testimony'] ?? '',
          notes: data['notes'] ?? '',
          attendees: data['attendees'] ?? 0,
          newMembers: data['new_members'] ?? 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load reports: ${e.toString()}');
    }
  }

  // Get all reports (admin only)
  static Future<List<WeeklyReport>> getAllReports() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_reportsEndpoint/all'),
        headers: headers,
      );

      _handleError(response);

      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => _parseReportFromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load reports: ${e.toString()}');
    }
  }

  // Helper method to parse report from JSON
  static WeeklyReport _parseReportFromJson(Map<String, dynamic> data) {
    return WeeklyReport(
      id: data['id'].toString(),
      mcName: data['mc_name'] ?? '',
      leaderName: data['leader_name'] ?? '',
      location: data['location'] ?? '',
      weekStarting: DateTime.parse(data['week_starting']),
      meetingDate: DateTime.parse(data['meeting_date']),
      submissionDate: DateTime.parse(data['submission_date']),
      submittedBy: data['submitted_by'] ?? '',
      approved: data['approved'] == 1,
      adultCount: data['adult_count'] ?? 0,
      childrenCount: data['children_count'] ?? 0,
      visitorCount: data['visitor_count'] ?? 0,
      devotionalTopic: data['devotional_topic'] ?? '',
      prayerRequests: data['prayer_requests'] ?? '',
      testimony: data['testimony'] ?? '',
      notes: data['notes'] ?? '',
      attendees: data['attendees'] ?? 0,
      newMembers: data['new_members'] ?? 0,
    );
  }

  // Get reports for a specific MC group
  static Future<List<WeeklyReport>> getMcReports(String mcName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_reportsEndpoint?mc_name=$mcName'),
        headers: headers,
      );

      _handleError(response);

      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => _parseReportFromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load MC reports: ${e.toString()}');
    }
  }

  // Add a new report
  static Future<String> addReport(WeeklyReport report) async {
    final userId = await currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final headers = await _getHeaders();

      // Convert the report to a map with snake_case keys for the API
      final reportData = {
        'mc_name': report.mcName,
        'leader_name': report.leaderName,
        'location': report.location,
        'week_starting': report.weekStarting.toIso8601String(),
        'meeting_date': report.meetingDate.toIso8601String(),
        'submitted_by': userId,
        'adult_count': report.adultCount,
        'children_count': report.childrenCount,
        'visitor_count': report.visitorCount,
        'devotional_topic': report.devotionalTopic,
        'prayer_requests': report.prayerRequests,
        'testimony': report.testimony,
        'notes': report.notes,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_reportsEndpoint'),
        headers: headers,
        body: json.encode(reportData),
      );

      _handleError(response);

      final responseData = json.decode(response.body);
      return responseData['id'].toString();
    } catch (e) {
      throw Exception('Failed to submit report: ${e.toString()}');
    }
  }

  // Update an existing report
  static Future<void> updateReport(WeeklyReport report) async {
    final userId = await currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final headers = await _getHeaders();

      // Convert the report to a map with snake_case keys for the API
      final reportData = {
        'mc_name': report.mcName,
        'leader_name': report.leaderName,
        'location': report.location,
        'week_starting': report.weekStarting.toIso8601String(),
        'meeting_date': report.meetingDate.toIso8601String(),
        'adult_count': report.adultCount,
        'children_count': report.childrenCount,
        'visitor_count': report.visitorCount,
        'devotional_topic': report.devotionalTopic,
        'prayer_requests': report.prayerRequests,
        'testimony': report.testimony,
        'notes': report.notes,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl$_reportsEndpoint/${report.id}'),
        headers: headers,
        body: json.encode(reportData),
      );

      _handleError(response);
    } catch (e) {
      throw Exception('Failed to update report: ${e.toString()}');
    }
  }

  // Delete a report
  static Future<void> deleteReport(String reportId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$_baseUrl$_reportsEndpoint/$reportId'),
        headers: headers,
      );

      _handleError(response);
    } catch (e) {
      throw Exception('Failed to delete report: ${e.toString()}');
    }
  }

  // Approve a report (admin only)
  static Future<void> approveReport(String reportId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('$_baseUrl$_reportsEndpoint/$reportId/approve'),
        headers: headers,
        body: json.encode({'approved': true}),
      );

      _handleError(response);
    } catch (e) {
      throw Exception('Failed to approve report: ${e.toString()}');
    }
  }

  // Get a single report by ID
  static Future<WeeklyReport> getReportById(String reportId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl$_reportsEndpoint/$reportId'),
        headers: headers,
      );

      _handleError(response);

      final responseData = json.decode(response.body);
      return _parseReportFromJson(responseData);
    } catch (e) {
      throw Exception('Failed to load report: ${e.toString()}');
    }
  }

  // Get reports for a date range
  static Future<List<WeeklyReport>> getReportsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final headers = await _getHeaders();

      final String startDateStr = startDate.toIso8601String().split('T')[0];
      final String endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse(
          '$_baseUrl$_reportsEndpoint?start_date=$startDateStr&end_date=$endDateStr',
        ),
        headers: headers,
      );

      _handleError(response);

      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => _parseReportFromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load reports by date range: ${e.toString()}');
    }
  }

  // Get reports statistics
  static Future<Map<String, dynamic>> getReportsStatistics() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl$_statsEndpoint'),
        headers: headers,
      );

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to load statistics: ${e.toString()}');
    }
  }

  static Future<List<WeeklyReport>> getRecentReports() async {
    // Replace the following with actual implementation
    return Future.delayed(
      Duration(seconds: 1),
      () => [
        WeeklyReport(
          id: '1',
          mcName: 'MC 1',
          leaderName: 'Leader 1',
          location: 'Location 1',
          weekStarting: DateTime.now().subtract(Duration(days: 7)),
          meetingDate: DateTime.now().subtract(Duration(days: 6)),
          submissionDate: DateTime.now(),
          submittedBy: 'User 1',
          approved: false,
          adultCount: 15,
          childrenCount: 5,
          visitorCount: 5,
          devotionalTopic: 'Topic 1',
          prayerRequests: 'Prayer 1',
          testimony: 'Testimony 1',
          notes: 'Notes 1',
          attendees: 25,
          newMembers: 2,
        ),
        WeeklyReport(
          id: '2',
          mcName: 'MC 2',
          leaderName: 'Leader 2',
          location: 'Location 2',
          weekStarting: DateTime.now().subtract(Duration(days: 14)),
          meetingDate: DateTime.now().subtract(Duration(days: 13)),
          submissionDate: DateTime.now(),
          submittedBy: 'User 2',
          approved: true,
          adultCount: 20,
          childrenCount: 7,
          visitorCount: 3,
          devotionalTopic: 'Topic 2',
          prayerRequests: 'Prayer 2',
          testimony: 'Testimony 2',
          notes: 'Notes 2',
          attendees: 30,
          newMembers: 3,
        ),
      ],
    );
  }

  static Future<ReportSummary> getReportSummary() async {
    // Mock implementation or actual API call
    return ReportSummary(
      totalMCs: 10,
      totalMeetingsHeld: 20,
      totalAttendees: 300,
      totalNewMembers: 15,
    );
  }

  static Future<List<WeeklyReport>> getWeeklyReports({
    int? mcId,
    String? startDate,
    String? endDate,
  }) async {
    // Replace this with actual logic to fetch weekly reports
    // For example, make an API call or fetch data from a database
    return Future.delayed(
      Duration(seconds: 1),
      () => [
        WeeklyReport(
          id: 'sample_id',
          mcName: 'Sample MC',
          leaderName: 'Sample Leader',
          location: 'Sample Location',
          weekStarting: DateTime.now().subtract(Duration(days: 7)),
          meetingDate: DateTime.now().subtract(Duration(days: 6)),
          submissionDate: DateTime.now(),
          submittedBy: 'Sample User',
          approved: false,
          adultCount: 10,
          childrenCount: 5,
          visitorCount: 2,
          devotionalTopic: 'Sample Topic',
          prayerRequests: 'Sample Prayer Requests',
          testimony: 'Sample Testimony',
          notes: 'Sample Notes',
          attendees: 10,
          newMembers: 2,
        ),
      ],
    );
  }

  // Get MC statistics (mock implementation)
  static Future<Map<String, dynamic>> getMCStats() async {
    // Replace with actual implementation to fetch MC stats
    return {
      'totalMembers': 50,
      'meetingsHeld': 20,
      'avgAttendance': 30,
      'newMembers': 5,
    };
  }

  // Login user and save token
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      _handleError(response);

      final responseData = json.decode(response.body);

      // Save token and user info to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', responseData['token']);
      await prefs.setString('user_id', responseData['user_id'].toString());
      await prefs.setString('user_name', responseData['name'] ?? '');
      await prefs.setBool('is_admin', responseData['is_admin'] == 1);

      return true;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('is_admin');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }
}
