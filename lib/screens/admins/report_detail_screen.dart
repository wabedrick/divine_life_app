// lib/screens/super_admin/report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weekly_report_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final WeeklyReport report;

  // ignore: use_key_in_widget_constructors
  const ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.mcName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                        SizedBox(width: 4),
                        Text('Meeting Date: ${report.meetingDate}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blueGrey),
                        SizedBox(width: 4),
                        Text('Leader: ${report.leaderName}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.blueGrey),
                        SizedBox(width: 4),
                        Text('Attendance: ${report.attendance}'),
                        SizedBox(width: 16),
                        Icon(Icons.person_add, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text('New Members: ${report.newMember}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.blueGrey),
                        SizedBox(width: 4),
                        Text('Meet Up: ${report.meetUp}'),
                        SizedBox(width: 16),
                        Icon(Icons.attach_money, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text('Giving: \$${report.giving.toStringAsFixed(2)}'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Comment:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(report.comment),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
