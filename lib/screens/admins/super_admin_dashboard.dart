import 'package:divine_life_app/services/mc_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/report_summary_model.dart';
import '../../models/weekly_report_model.dart';
import 'admin_management.dart';
import 'mc_management_screen.dart';
import 'reports_screen.dart';
import 'report_detail_screen.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../../utils/app_colors.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class WeeklySummaryDashboard extends StatelessWidget {
  final Map<String, dynamic> summary;
  const WeeklySummaryDashboard({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildSummaryCard('MCs Met', summary['mcsMet'].toString(), Icons.check_circle, AppColors.primary, context),
        _buildSummaryCard('Did Not Meet', summary['mcsDidNotMeet'].toString(), Icons.cancel, AppColors.dark, context),
        _buildSummaryCard('Attendance', summary['totalAttendance'].toString(), Icons.people, AppColors.primary, context),
        _buildSummaryCard('New Members', summary['totalNewMembers'].toString(), Icons.person_add, AppColors.primary, context),
        _buildSummaryCard('Giving', 'UGX ${summary['totalGiving']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, AppColors.primary, context),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width - 48) / 2; // 16 padding * 2 + 16 spacing
    return SizedBox(
      width: cardWidth,
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: AppColors.dark.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  Map<String, dynamic>? weeklySummary;
  bool isLoadingSummary = true;
  List<WeeklyReport> recentReports = [];
  bool isLoading = true;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadWeeklySummary();
    _loadDashboardData();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.logout();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickWeek(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedStartDate != null && selectedEndDate != null
          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
      });
      await _loadWeeklySummary();
      await _loadDashboardData();
    }
  }

  Future<void> _loadWeeklySummary() async {
    setState(() => isLoadingSummary = true);
    try {
      final summary = await McServices.fetchWeeklySummary(
        startDate: selectedStartDate?.toIso8601String().split('T')[0],
        endDate: selectedEndDate?.toIso8601String().split('T')[0],
      );
      setState(() {
        weeklySummary = summary;
        isLoadingSummary = false;
      });
    } catch (e) {
      setState(() => isLoadingSummary = false);
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);
    try {
      final reports = await McServices.fetchAllReports(
        startDate: selectedStartDate?.toIso8601String().split('T')[0],
        endDate: selectedEndDate?.toIso8601String().split('T')[0],
      );
      setState(() {
        recentReports = reports;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Super Admin Dashboard')),
        body: Center(child: CircularProgressIndicator()),
        drawer: _buildDrawer(context),
      );
    }
    // Get week range string if available
    String weekRange = '';
    DateTime? start;
    DateTime? end;
    if (selectedStartDate != null && selectedEndDate != null) {
      start = selectedStartDate;
      end = selectedEndDate;
    } else if (weeklySummary != null && weeklySummary!['startDate'] != null && weeklySummary!['endDate'] != null) {
      start = DateTime.parse(weeklySummary!['startDate']);
      end = DateTime.parse(weeklySummary!['endDate']);
    }
    if (start != null && end != null) {
      weekRange = 'Week: '
        + '${start.day}/${start.month}/${start.year}'
        + ' - '
        + '${(end.subtract(Duration(days: 1))).day}/${(end.subtract(Duration(days: 1))).month}/${(end.subtract(Duration(days: 1))).year}';
    }
    print('WEEK RANGE: ' + weekRange);
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: AppColors.dark,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            selectedStartDate = null;
            selectedEndDate = null;
          });
          await _loadWeeklySummary();
          await _loadDashboardData();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (weekRange.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    weekRange,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              isLoadingSummary
                ? Center(child: CircularProgressIndicator())
                : (weeklySummary == null)
                  ? Center(child: Text('No summary available'))
                  : WeeklySummaryDashboard(summary: weeklySummary!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickWeek(context),
                child: Text('Select Week'),
              ),
              SizedBox(height: 24),
              Text(
                'Recent Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              _buildRecentReportsList(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                },
                child: Text('View All Reports'),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Super Admin',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Management Panel',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.blue),
            title: Text('Dashboard', style: TextStyle(color: Colors.blue)),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Admin Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.groups),
            title: Text('MC Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MCManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assessment),
            title: Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportsScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),

            onTap: () async {
              // await ApiService.logout();
              // ignore: use_build_context_synchronously
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList() {
    if (recentReports.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recent reports found'),
        ),
      );
    }
    // Show only the two most recent reports
    final latestReports = recentReports.take(2).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: latestReports.length,
      itemBuilder: (context, index) {
        final report = latestReports[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(report.mcName),
            subtitle: Text('Meeting Date: ${report.meetingDate}'),
            trailing: Text('${report.attendance} attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportDetailScreen(report: report),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
