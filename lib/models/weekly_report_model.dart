import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReport {
  final int id;
  final String meetingDate;
  final String mcName;
  final int attendance;
  final int newMember;
  final String meetUp;
  final double giving;
  final String leaderName;
  final String comment;

  WeeklyReport({
    required this.id,
    required this.meetingDate,
    required this.mcName,
    required this.attendance,
    required this.newMember,
    required this.meetUp,
    required this.giving,
    required this.leaderName,
    required this.comment,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      meetingDate: json['meetingDate'] ?? '',
      mcName: json['mcName'] ?? '',
      attendance: json['attendance'] is int ? json['attendance'] : int.tryParse(json['attendance'].toString()) ?? 0,
      newMember: json['newMember'] is int ? json['newMember'] : int.tryParse(json['newMember'].toString()) ?? 0,
      meetUp: json['meetUp'] ?? '',
      giving: json['giving'] is double ? json['giving'] : double.tryParse(json['giving'].toString()) ?? 0.0,
      leaderName: json['leaderName'] ?? '',
      comment: json['comment'] ?? '',
    );
  }

  // Create an empty report with default values
  factory WeeklyReport.empty() {
    return WeeklyReport(
      id: 0,
      meetingDate: '',
      mcName: '',
      attendance: 0,
      newMember: 0,
      meetUp: '',
      giving: 0.0,
      leaderName: '',
      comment: '',
    );
  }

  // Create a report from Firestore document
  factory WeeklyReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WeeklyReport(
      id: data['id'] ?? 0,
      meetingDate: data['meetingDate'] ?? '',
      mcName: data['mcName'] ?? '',
      attendance: data['attendance'] ?? 0,
      newMember: data['newMember'] ?? 0,
      meetUp: data['meetUp'] ?? '',
      giving: data['giving'] ?? 0.0,
      leaderName: data['leaderName'] ?? '',
      comment: data['comment'] ?? '',
    );
  }

  // Convert report to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'meetingDate': meetingDate,
      'mcName': mcName,
      'attendance': attendance,
      'newMember': newMember,
      'meetUp': meetUp,
      'giving': giving,
      'leaderName': leaderName,
      'comment': comment,
    };
  }

  // Create a copy of the report with modified fields
  WeeklyReport copyWith({
    int? id,
    String? meetingDate,
    String? mcName,
    int? attendance,
    int? newMember,
    String? meetUp,
    double? giving,
    String? leaderName,
    String? comment,
  }) {
    return WeeklyReport(
      id: id ?? this.id,
      meetingDate: meetingDate ?? this.meetingDate,
      mcName: mcName ?? this.mcName,
      attendance: attendance ?? this.attendance,
      newMember: newMember ?? this.newMember,
      meetUp: meetUp ?? this.meetUp,
      giving: giving ?? this.giving,
      leaderName: leaderName ?? this.leaderName,
      comment: comment ?? this.comment,
    );
  }

  @override
  String toString() {
    return 'WeeklyReport(id: $id, mcName: $mcName, leaderName: $leaderName, meetingDate: $meetingDate)';
  }
}
