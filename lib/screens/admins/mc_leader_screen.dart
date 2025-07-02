import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mc_member_model.dart';
import '../../models/weekly_report_model.dart';
import '../../services/auth_service.dart';
import '../../services/mc_services.dart';
import '../../../services/mc_member_service.dart';
import '../login_screen.dart';
import './mcs/mc_members_screen.dart';
import 'mcs/add_edit_member_screen.dart';
import './mcs/weekly_reports_screen.dart';
import './mcs/submit_report_screen.dart';
import 'report_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MCLeaderDashboard extends StatefulWidget {
  const MCLeaderDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MCLeaderDashboardState createState() => _MCLeaderDashboardState();
}

class _MCLeaderDashboardState extends State<MCLeaderDashboard> {
  bool isLoading = true;
  List<MCMember> recentMembers = [];
  List<WeeklyReport> recentReports = [];
  Map<String, dynamic> mcStats = {};
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
      // Retrieve MC name from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final mcName = prefs.getString('mc') ?? '';
      // Load recent members, reports and stats for this MC
      final membersResponse = await McMemberServices.getMembers(mcName: mcName);
      final reportsResponse = await McServices.fetchAllReports(mcName: mcName);
      final statsResponse = await McServices.getMCStats(mcName: mcName);

      setState(() {
        recentMembers = membersResponse;
        recentReports = reportsResponse;
        mcStats = statsResponse;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
        appBar: AppBar(title: Text('MC Leader Dashboard')),
        body: Center(child: CircularProgressIndicator()),
        drawer: _buildDrawer(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('MC Leader Dashboard'),
        backgroundColor: Colors.green,
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
              _buildActionButtons(context),
              SizedBox(height: 24),
              Text(
                'Recent Members',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              _buildRecentMembersList(),
              SizedBox(height: 24),
              Text(
                'Recent Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              _buildRecentReportsList(),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubmitReportScreen()),
          ).then((_) => _loadDashboardData());
        },
        backgroundColor: Colors.green,
        tooltip: 'Submit Weekly Report',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'MC Leader',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Ministry Management',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.green),
            title: Text('Dashboard', style: TextStyle(color: Colors.green)),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('MC Members'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MCMembersScreen()),
              ).then((_) => _loadDashboardData());
            },
          ),
          ListTile(
            leading: Icon(Icons.assessment),
            title: Text('Weekly Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeeklyReportsScreen()),
              ).then((_) => _loadDashboardData());
            },
          ),
          ListTile(
            leading: Icon(Icons.add_chart),
            title: Text('Submit New Report'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubmitReportScreen()),
              ).then((_) => _loadDashboardData());
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
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
          'Total Members',
          '${mcStats['totalMembers'] ?? 0}',
          Icons.people,
        ),
        _buildSummaryCard(
          'Meetings Held',
          '${mcStats['meetingsHeld'] ?? 0}',
          Icons.calendar_today,
        ),
        _buildSummaryCard(
          'Avg Attendance',
          '${mcStats['avgAttendance'] ?? 0}',
          Icons.person,
        ),
        _buildSummaryCard(
          'New Members',
          '${mcStats['newMembers'] ?? 0}',
          Icons.person_add,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditMemberScreen()),
            ).then((_) => _loadDashboardData());
          },
          icon: Icon(Icons.person_add),
          label: Text('Add Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubmitReportScreen()),
            ).then((_) => _loadDashboardData());
          },
          icon: Icon(Icons.add_chart),
          label: Text('Submit Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
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
            Icon(icon, size: 32, color: Colors.green),
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

  Widget _buildRecentMembersList() {
    if (recentMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No members found'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          ...recentMembers
              .take(3)
              .map(
                (member) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.phone ?? 'No phone number'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddEditMemberScreen(member: member),
                      ),
                    ).then((_) => _loadDashboardData());
                  },
                ),
              ),
          Divider(height: 1),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MCMembersScreen()),
              ).then((_) => _loadDashboardData());
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('View All Members'),
            ),
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
          child: Text('No reports found'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          ...recentReports
              .take(3)
              .map(
                (report) => ListTile(
                  title: Text(
                    'Week of [32m[1m[4m${DateFormat('MMM d, yyyy').format(DateTime.parse(report.meetingDate))}[0m',
                  ),
                  subtitle: Text('${report.attendance} attendance'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ReportDetailScreen(report: report),
                      ),
                    ).then((_) => _loadDashboardData());
                  },
                ),
              ),
          Divider(height: 1),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeeklyReportsScreen()),
              ).then((_) => _loadDashboardData());
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('View All Reports'),
            ),
          ),
        ],
      ),
    );
  }
}
