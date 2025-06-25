import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReport {
  final String id;
  final String mcName;
  final String leaderName;
  final String location;
  final DateTime weekStarting;
  final DateTime meetingDate;
  final DateTime submissionDate;
  final String submittedBy;
  final bool approved;
  final int attendees;
  final int newMembers;

  // Attendance counts
  final int adultCount;
  final int childrenCount;
  final int visitorCount;

  // Meeting content
  final String devotionalTopic;
  final String prayerRequests;
  final String testimony;
  final String notes;

  const WeeklyReport({
    required this.id,
    required this.mcName,
    required this.leaderName,
    required this.location,
    required this.weekStarting,
    required this.meetingDate,
    required this.submissionDate,
    required this.submittedBy,
    required this.approved,
    required this.adultCount,
    required this.childrenCount,
    required this.visitorCount,
    required this.devotionalTopic,
    required this.prayerRequests,
    required this.testimony,
    required this.notes,
    required this.attendees,
    required this.newMembers,
  });

  // Create an empty report with default values
  factory WeeklyReport.empty() {
    return WeeklyReport(
      id: '',
      mcName: '',
      leaderName: '',
      location: '',
      weekStarting: DateTime.now(),
      meetingDate: DateTime.now(),
      submissionDate: DateTime.now(),
      submittedBy: '',
      approved: false,
      adultCount: 0,
      childrenCount: 0,
      visitorCount: 0,
      devotionalTopic: '',
      prayerRequests: '',
      testimony: '',
      notes: '',
      attendees: 0,
      newMembers: 0,
    );
  }

  // Create a report from Firestore document
  factory WeeklyReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WeeklyReport(
      id: doc.id,
      mcName: data['mcName'] ?? '',
      leaderName: data['leaderName'] ?? '',
      location: data['location'] ?? '',
      weekStarting: (data['weekStarting'] as Timestamp).toDate(),
      meetingDate: (data['meetingDate'] as Timestamp).toDate(),
      submissionDate: (data['submissionDate'] as Timestamp).toDate(),
      submittedBy: data['submittedBy'] ?? '',
      approved: data['approved'] ?? false,
      adultCount: data['adultCount'] ?? 0,
      childrenCount: data['childrenCount'] ?? 0,
      visitorCount: data['visitorCount'] ?? 0,
      devotionalTopic: data['devotionalTopic'] ?? '',
      prayerRequests: data['prayerRequests'] ?? '',
      testimony: data['testimony'] ?? '',
      notes: data['notes'] ?? '',
      attendees: data['attendees'] ?? 0,
      newMembers: data['newMembers'] ?? 0,
    );
  }

  // Convert report to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'mcName': mcName,
      'leaderName': leaderName,
      'location': location,
      'weekStarting': Timestamp.fromDate(weekStarting),
      'meetingDate': Timestamp.fromDate(meetingDate),
      'submissionDate': Timestamp.fromDate(submissionDate),
      'submittedBy': submittedBy,
      'approved': approved,
      'adultCount': adultCount,
      'childrenCount': childrenCount,
      'visitorCount': visitorCount,
      'devotionalTopic': devotionalTopic,
      'prayerRequests': prayerRequests,
      'testimony': testimony,
      'notes': notes,
    };
  }

  // Create a copy of the report with modified fields
  WeeklyReport copyWith({
    String? id,
    String? mcName,
    String? leaderName,
    String? location,
    DateTime? weekStarting,
    DateTime? meetingDate,
    DateTime? submissionDate,
    String? submittedBy,
    bool? approved,
    int? adultCount,
    int? childrenCount,
    int? visitorCount,
    String? devotionalTopic,
    String? prayerRequests,
    String? testimony,
    String? notes,
  }) {
    return WeeklyReport(
      id: id ?? this.id,
      mcName: mcName ?? this.mcName,
      leaderName: leaderName ?? this.leaderName,
      location: location ?? this.location,
      weekStarting: weekStarting ?? this.weekStarting,
      meetingDate: meetingDate ?? this.meetingDate,
      submissionDate: submissionDate ?? this.submissionDate,
      submittedBy: submittedBy ?? this.submittedBy,
      approved: approved ?? this.approved,
      adultCount: adultCount ?? this.adultCount,
      childrenCount: childrenCount ?? this.childrenCount,
      visitorCount: visitorCount ?? this.visitorCount,
      devotionalTopic: devotionalTopic ?? this.devotionalTopic,
      prayerRequests: prayerRequests ?? this.prayerRequests,
      testimony: testimony ?? this.testimony,
      notes: notes ?? this.notes,
      attendees: attendees,
      newMembers: newMembers,
    );
  }

  // Calculate total attendance
  int get totalAttendance => adultCount + childrenCount + visitorCount;

  @override
  String toString() {
    return 'WeeklyReport(id: $id, mcName: $mcName, leaderName: $leaderName, meetingDate: $meetingDate)';
  }
}
