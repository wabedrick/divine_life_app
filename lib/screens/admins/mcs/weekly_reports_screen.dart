import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weekly_report_model.dart';
import '../../../services/mc_services.dart';
import 'report_detail_screen.dart';
import 'submit_report_screen.dart';

class WeeklyReportsScreen extends StatefulWidget {
  const WeeklyReportsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeeklyReportsScreenState createState() => _WeeklyReportsScreenState();
}

class _WeeklyReportsScreenState extends State<WeeklyReportsScreen> {
  List<WeeklyReport> reports = [];
  bool isLoading = true;
  String filterStatus = 'All';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      isLoading = true;
    });

    try {
      final reportsResponse = await McServices.getLeaderReports();
      setState(() {
        reports = reportsResponse;
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
        SnackBar(content: Text('Error loading reports: ${e.toString()}')),
      );
    }
  }

  List<WeeklyReport> get filteredReports {
    return reports.where((report) {
      bool passesDateFilter = true;

      if (startDate != null) {
        passesDateFilter =
            report.weekStarting.isAfter(startDate!) ||
            report.weekStarting.isAtSameMomentAs(startDate!);
      }

      if (passesDateFilter && endDate != null) {
        passesDateFilter =
            report.weekStarting.isBefore(endDate!) ||
            report.weekStarting.isAtSameMomentAs(endDate!);
      }

      return passesDateFilter;
    }).toList();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  void _deleteReport(WeeklyReport report) async {
    final bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Delete Report'),
                content: Text(
                  'Are you sure you want to delete this report? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      try {
        await McServices.deleteReport(report.id);
        _loadReports();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Reports'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterSheet(context);
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          if (startDate != null || endDate != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered: ${startDate != null ? DateFormat('MMM d, yyyy').format(startDate!) : 'Any'} - '
                      '${endDate != null ? DateFormat('MMM d, yyyy').format(endDate!) : 'Any'}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(onPressed: _clearFilters, child: Text('Clear')),
                ],
              ),
            ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredReports.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reports found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubmitReportScreen(),
                                ),
                              ).then((_) => _loadReports());
                            },
                            icon: Icon(Icons.add),
                            label: Text('Submit New Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(
                              'Week of ${DateFormat('MMM d, yyyy').format(report.weekStarting)}',
                            ),
                            subtitle: Text(
                              '${report.attendees} attendees, ${report.newMembers} new members',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SubmitReportScreen(
                                              report: report,
                                            ),
                                      ),
                                    ).then((_) => _loadReports());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteReport(report),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ReportDetailScreen(report: report),
                                ),
                              ).then((_) => _loadReports());
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubmitReportScreen()),
          ).then((_) => _loadReports());
        },
        backgroundColor: Colors.green,
        tooltip: 'Submit New Report',
        child: Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Reports',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Date Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _selectStartDate(context);
                          },
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                            startDate != null
                                ? DateFormat('MMM d, yyyy').format(startDate!)
                                : 'Start Date',
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _selectEndDate(context);
                          },
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                            endDate != null
                                ? DateFormat('MMM d, yyyy').format(endDate!)
                                : 'End Date',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            startDate = null;
                            endDate = null;
                          });
                          Navigator.pop(context);
                          setState(() {
                            _clearFilters();
                          });
                        },
                        child: Text('Clear All'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
