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

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  ReportSummary? summary;
  List<WeeklyReport> recentReports = [];
  bool isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load summary and recent reports
      final summaryResponse = await McServices.getReportSummary();
      final reportsResponse = await McServices.getRecentReports();

      setState(() {
        summary = summaryResponse;
        recentReports = reportsResponse;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: ${e.toString()}')),
      );
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
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
                child: Text(
                  'View All Reports',
                  style: TextStyle(color: Colors.blue),
                ),
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

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          'Total MCs',
          '${summary?.totalMCs ?? 0}',
          Icons.group,
        ),
        _buildSummaryCard(
          'Meetings Held',
          '${summary?.totalMeetingsHeld ?? 0}',
          Icons.calendar_today,
        ),
        _buildSummaryCard(
          'Total Attendees',
          '${summary?.totalAttendees ?? 0}',
          Icons.people,
        ),
        _buildSummaryCard(
          'New Members',
          '${summary?.totalNewMembers ?? 0}',
          Icons.person_add,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recentReports.length,
      itemBuilder: (context, index) {
        final report = recentReports[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(report.mcName ?? 'Unknown MC'),
            subtitle: Text(
              'Week of ${DateFormat('MMM d, yyyy').format(report.weekStarting)}',
            ),
            trailing: Text('${report.attendees} attendees'),
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
