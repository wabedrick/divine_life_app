// lib/models/report_summary.dart
class ReportSummary {
  final int totalMCs;
  final int totalMeetingsHeld;
  final int totalAttendees;
  final int totalNewMembers;

  ReportSummary({
    required this.totalMCs,
    required this.totalMeetingsHeld,
    required this.totalAttendees,
    required this.totalNewMembers,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalMCs: json['total_mcs'],
      totalMeetingsHeld: json['total_meetings_held'],
      totalAttendees: json['total_attendees'],
      totalNewMembers: json['total_new_members'],
    );
  }
}
