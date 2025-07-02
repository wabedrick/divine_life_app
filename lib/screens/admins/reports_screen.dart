import 'package:divine_life_app/services/mc_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mc_model.dart';
import '../../models/weekly_report_model.dart';
import '../../services/missional_community_service.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<WeeklyReport> reports = [];
  List<MissionalCommunity> mcs = [];
  bool isLoading = true;

  // Filter variables
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedMcId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final mcsList = await MissionalCommunityService.getAllMCs();
      await _loadReports();

      setState(() {
        mcs = mcsList.cast<MissionalCommunity>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadReports() async {
    try {
      final reportsList = await McServices.fetchAllReports();
      setState(() {
        reports = reportsList;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: ${e.toString()}')),
      );
    }
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReports();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedMcId = null;
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadReports,
                child:
                    reports.isEmpty
                        ? Center(child: Text('No reports found'))
                        : ListView.builder(
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.mcName,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                                        SizedBox(width: 4),
                                        Text('Meeting Date: ${report.meetingDate}'),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 16, color: Colors.blueGrey),
                                        SizedBox(width: 4),
                                        Text('Leader: ${report.leaderName}'),
                                      ],
                                    ),
                                    SizedBox(height: 4),
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
                                    SizedBox(height: 4),
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
                                    SizedBox(height: 8),
                                    Text(
                                      'Comment:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(report.comment),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filter Reports',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Date Range'),
                    subtitle:
                        _startDate != null && _endDate != null
                            ? Text(
                              '${DateFormat('MMM d, yyyy').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                            )
                            : Text('All time'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () {
                      Navigator.pop(context);
                      _selectDateRange();
                    },
                  ),
                  DropdownButtonFormField<int?>(
                    decoration: InputDecoration(
                      labelText: 'Micro Community',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMcId,
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Micro Communities'),
                      ),
                      ...mcs.map(
                        (mc) => DropdownMenuItem<int?>(
                          value: mc.id,
                          child: Text(mc.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        _selectedMcId = value;
                      });
                      setState(() {
                        _selectedMcId = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearFilters();
                        },
                        child: Text('CLEAR FILTERS'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadReports();
                        },
                        child: Text('APPLY'),
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
