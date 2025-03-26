// lib/models/weekly_report.dart
class WeeklyReport {
  final int? id;
  final int mcId;
  final String? mcName;
  final DateTime weekStarting;
  final int attendees;
  final int newMembers;
  final String meetingNotes;
  final String challenges;
  final DateTime submittedAt;

  WeeklyReport({
    this.id,
    required this.mcId,
    this.mcName,
    required this.weekStarting,
    required this.attendees,
    required this.newMembers,
    required this.meetingNotes,
    required this.challenges,
    required this.submittedAt,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      id: json['id'],
      mcId: json['mc_id'],
      mcName: json['mc_name'],
      weekStarting: DateTime.parse(json['week_starting']),
      attendees: json['attendees'],
      newMembers: json['new_members'],
      meetingNotes: json['meeting_notes'],
      challenges: json['challenges'],
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'mc_id': mcId,
      'week_starting': weekStarting.toIso8601String().split('T')[0],
      'attendees': attendees,
      'new_members': newMembers,
      'meeting_notes': meetingNotes,
      'challenges': challenges,
    };

    if (id != null) data['id'] = id;

    return data;
  }
}
