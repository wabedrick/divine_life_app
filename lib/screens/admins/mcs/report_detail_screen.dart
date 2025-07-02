import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weekly_report_model.dart';
import 'submit_report_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final WeeklyReport report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubmitReportScreen(report: report),
                ),
              ).then((_) => Navigator.pop(context));
            },
            tooltip: 'Edit Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 8),
                Text('Meeting Date: ${report.meetingDate}', style: TextStyle(fontSize: 18)),
                Divider(height: 24),
                Text('MC Name: ${report.mcName}', style: TextStyle(fontSize: 16)),
                Text('Leader Name: ${report.leaderName}', style: TextStyle(fontSize: 16)),
                Text('Attendance: ${report.attendance}', style: TextStyle(fontSize: 16)),
                Text('New Members: ${report.newMember}', style: TextStyle(fontSize: 16)),
                Text('Meet Up: ${report.meetUp}', style: TextStyle(fontSize: 16)),
                Text('Giving: ${report.giving}', style: TextStyle(fontSize: 16)),
                Text('Comment: ${report.comment}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
