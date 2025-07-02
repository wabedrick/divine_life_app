import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weekly_report_model.dart';
import '../../../services/mc_services.dart';

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
    }
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
        // Call your service to submit the report here (e.g., McServices.submitReport(reportData));
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
          SnackBar(content: Text('Error saving report: e'), backgroundColor: Colors.red),
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
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _mcNameController,
                              decoration: InputDecoration(
                                labelText: 'MC Name *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.group, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter MC name' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _leaderNameController,
                              decoration: InputDecoration(
                                labelText: 'Leader Name *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter leader name' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _attendanceController,
                              decoration: InputDecoration(
                                labelText: 'Attendance *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.people, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter attendance' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _newMemberController,
                              decoration: InputDecoration(
                                labelText: 'New Members *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_add, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter new members' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _meetUpController,
                              decoration: InputDecoration(
                                labelText: 'Meet Up *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter meet up info' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _givingController,
                              decoration: InputDecoration(
                                labelText: 'Giving *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter giving' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                labelText: 'Comment',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.comment, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              initialValue: _meetingDate,
                              decoration: InputDecoration(
                                labelText: 'Meeting Date *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              onChanged: (value) => _meetingDate = value,
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
    super.dispose();
  }
}
