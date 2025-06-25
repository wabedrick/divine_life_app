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
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _newMembersController = TextEditingController();
  final TextEditingController _devotionalTopicController =
      TextEditingController();
  final TextEditingController _prayerRequestsController =
      TextEditingController();
  final TextEditingController _testimonyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _meetingDate = DateTime.now();
  bool _isLoading = false;
  bool _lateSubmission = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      // Editing existing report
      _mcNameController.text = widget.report!.mcName;
      _leaderNameController.text = widget.report!.leaderName;
      _locationController.text = widget.report!.location;
      _attendeesController.text = widget.report!.attendees.toString();
      _newMembersController.text = widget.report!.newMembers.toString();
      _devotionalTopicController.text = widget.report!.devotionalTopic;
      _prayerRequestsController.text = widget.report!.prayerRequests;
      _testimonyController.text = widget.report!.testimony;
      _notesController.text = widget.report!.notes;
      _meetingDate = widget.report!.weekStarting;
      // _lateSubmission = widget.report!.lateSubmission;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _meetingDate) {
      setState(() {
        _meetingDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final reportData = WeeklyReport(
          id: widget.report?.id ?? '',
          mcName: _mcNameController.text.trim(),
          leaderName: _leaderNameController.text.trim(),
          weekStarting: _meetingDate,
          location: _locationController.text.trim(),
          attendees: int.parse(_attendeesController.text.trim()),
          newMembers: int.parse(_newMembersController.text.trim()),
          devotionalTopic: _devotionalTopicController.text.trim(),
          prayerRequests: _prayerRequestsController.text.trim(),
          testimony: _testimonyController.text.trim(),
          notes: _notesController.text.trim(),
          // lateSubmission: _lateSubmission,
          submissionDate: DateTime.now(),
          meetingDate: _meetingDate,
          submittedBy: 'Admin', // Replace with actual user info if available
          approved: false, // Default value, adjust as needed
          adultCount: 0, // Replace with actual value if available
          childrenCount: 0, // Replace with actual value if available
          visitorCount: 0, // Replace with actual value if available
        );

        if (widget.report == null) {
          // Submit new report
          await McServices.addReport(reportData);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Update existing report
          await McServices.updateReport(reportData);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
      body:
          _isLoading
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
                              Text(
                                'Basic Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _mcNameController,
                                decoration: InputDecoration(
                                  labelText: 'MC Name *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.group),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter MC name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _leaderNameController,
                                decoration: InputDecoration(
                                  labelText: 'Leader Name *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter leader name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Meeting Date *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'MMMM dd, yyyy',
                                        ).format(_meetingDate),
                                      ),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _locationController,
                                decoration: InputDecoration(
                                  labelText: 'Meeting Location *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter meeting location';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _attendeesController,
                                decoration: InputDecoration(
                                  labelText: 'Total Attendees *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.people),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter attendees count';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _newMembersController,
                                decoration: InputDecoration(
                                  labelText: 'New Members *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_add),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter new members count';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meeting Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _devotionalTopicController,
                                decoration: InputDecoration(
                                  labelText: 'Devotional Topic',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.book),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _prayerRequestsController,
                                decoration: InputDecoration(
                                  labelText: 'Prayer Requests',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.favorite),
                                ),
                                maxLines: 3,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _testimonyController,
                                decoration: InputDecoration(
                                  labelText: 'Testimonies',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.star),
                                ),
                                maxLines: 3,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Additional Notes',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.note),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Late Submission'),
                        subtitle: Text(
                          'Mark if this report is being submitted late',
                        ),
                        value: _lateSubmission,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            _lateSubmission = value;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditing ? 'Update Report' : 'Submit Report',
                          style: TextStyle(fontSize: 16),
                        ),
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
    _locationController.dispose();
    _attendeesController.dispose();
    _newMembersController.dispose();
    _devotionalTopicController.dispose();
    _prayerRequestsController.dispose();
    _testimonyController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
