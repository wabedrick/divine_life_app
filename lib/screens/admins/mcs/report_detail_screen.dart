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
                // ignore: use_build_context_synchronously
              ).then((_) => Navigator.pop(context));
            },
            tooltip: 'Edit Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            SizedBox(height: 16),
            _buildSummaryStatsCard(),
            SizedBox(height: 16),
            _buildDetailCard('Meeting Content', [
              _buildDetailItem('Devotional Topic', report.devotionalTopic),
              _buildDetailItem('Prayer Requests', report.prayerRequests),
              _buildDetailItem('Testimonies', report.testimony),
              _buildDetailItem('Additional Notes', report.notes),
            ]),
            SizedBox(height: 16),
            _buildMetadataCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Report',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Week of ${DateFormat('MMMM dd, yyyy').format(report.weekStarting)}',
              style: TextStyle(fontSize: 18),
            ),
            Divider(height: 24),
            Row(
              children: [
                Icon(Icons.group, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(report.mcName, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Led by ${report.leaderName}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(report.location, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStatsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Adults',
                  report.adultCount.toString(),
                  Icons.people,
                ),
                _buildStatItem(
                  'Children',
                  report.childrenCount.toString(),
                  Icons.child_care,
                ),
                _buildStatItem(
                  'Visitors',
                  report.visitorCount.toString(),
                  Icons.person_add,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Total Attendance: ${report.adultCount + report.childrenCount + report.visitorCount}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDetailCard(String title, List<Widget> items) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Divider(height: 24),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            content.isEmpty ? 'None' : content,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Metadata',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Meeting Date: ${DateFormat('MMMM dd, yyyy').format(report.meetingDate)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Submitted on: ${DateFormat('MMMM dd, yyyy').format(report.submissionDate)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Submitted by: ${report.submittedBy}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            report.approved
                ? Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Approved',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pending Approval',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
