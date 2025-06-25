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
      // Prepare filter parameters
      Map<String, dynamic> filters = {};

      if (_startDate != null) {
        filters['start_date'] = DateFormat('yyyy-MM-dd').format(_startDate!);
      }

      if (_endDate != null) {
        filters['end_date'] = DateFormat('yyyy-MM-dd').format(_endDate!);
      }

      if (_selectedMcId != null) {
        filters['mc_id'] = _selectedMcId;
      }

      final reportsList = await McServices.getWeeklyReports(
        mcId: _selectedMcId,
        startDate:
            _startDate != null
                ? DateFormat('yyyy-MM-dd').format(_startDate!)
                : null,
        endDate:
            _endDate != null
                ? DateFormat('yyyy-MM-dd').format(_endDate!)
                : null,
      );

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
                              child: ListTile(
                                title: Text(report.mcName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      'Week of ${DateFormat('MMM d, yyyy').format(report.weekStarting)}',
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Attendees: ${report.attendees} (${report.newMembers} new)',
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ReportDetailScreen(
                                            report: report,
                                          ),
                                    ),
                                  );
                                },
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
