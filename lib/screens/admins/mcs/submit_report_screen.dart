import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weekly_report_model.dart';
import '../../../services/mc_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitReportScreen extends StatefulWidget {
  final WeeklyReport? report;

  const SubmitReportScreen({super.key, this.report});

  @override
  // ignore: library_private_types_in_public_api
  _SubmitReportScreenState createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mcNameController = TextEditingController();
  final TextEditingController _leaderNameController = TextEditingController();
  final TextEditingController _attendanceController = TextEditingController();
  final TextEditingController _newMemberController = TextEditingController();
  final TextEditingController _meetUpController = TextEditingController();
  final TextEditingController _givingController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _meetingDateController = TextEditingController();

  String _meetingDate = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _mcNameController.text = widget.report!.mcName;
      _leaderNameController.text = widget.report!.leaderName;
      _attendanceController.text = widget.report!.attendance.toString();
      _newMemberController.text = widget.report!.newMember.toString();
      _meetUpController.text = widget.report!.meetUp;
      _givingController.text = widget.report!.giving.toString();
      _commentController.text = widget.report!.comment;
      _meetingDate = widget.report!.meetingDate;
      _meetingDateController.text = _meetingDate;
    } else {
      _prefillUserInfo();
    }
  }

  Future<void> _prefillUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mcNameController.text = prefs.getString('mc') ?? '';
      _leaderNameController.text = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final reportData = WeeklyReport(
          id: widget.report?.id ?? 0,
          meetingDate: _meetingDate,
          mcName: _mcNameController.text.trim(),
          attendance: int.tryParse(_attendanceController.text.trim()) ?? 0,
          newMember: int.tryParse(_newMemberController.text.trim()) ?? 0,
          meetUp: _meetUpController.text.trim(),
          giving: double.tryParse(_givingController.text.trim()) ?? 0.0,
          leaderName: _leaderNameController.text.trim(),
          comment: _commentController.text.trim(),
        );
        await McServices.submitReport(reportData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving report: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.report != null;
    final title = isEditing ? 'Edit Weekly Report' : 'Submit Weekly Report';
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.green),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _mcNameController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'MC Name *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.group),
                                hintText: 'MC not found',
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter MC name' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _leaderNameController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Leader Name *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.person),
                                hintText: 'Leader not found',
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter leader name' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _attendanceController,
                              decoration: InputDecoration(
                                labelText: 'Attendance *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.people),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter attendance' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _newMemberController,
                              decoration: InputDecoration(
                                labelText: 'New Members *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.person_add),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter new members' : null,
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _meetUpController.text.isNotEmpty ? _meetUpController.text : null,
                              items: [
                                DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                                DropdownMenuItem(value: 'No', child: Text('No')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _meetUpController.text = value ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Meet Up *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.event),
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please select meet up' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _givingController,
                              decoration: InputDecoration(
                                labelText: 'Giving *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter giving' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                labelText: 'Comment',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.comment),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _meetingDateController,
                              readOnly: true,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _meetingDate.isNotEmpty
                                      ? DateTime.tryParse(_meetingDate) ?? DateTime.now()
                                      : DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _meetingDate = picked.toIso8601String().substring(0, 10);
                                    _meetingDateController.text = _meetingDate;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Meeting Date *',
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter meeting date' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(isEditing ? 'Update Report' : 'Submit Report'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _mcNameController.dispose();
    _leaderNameController.dispose();
    _attendanceController.dispose();
    _newMemberController.dispose();
    _meetUpController.dispose();
    _givingController.dispose();
    _commentController.dispose();
    _meetingDateController.dispose();
    super.dispose();
  }
}
