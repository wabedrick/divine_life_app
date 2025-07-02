// mc_member_model.dart
class MCMember {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime joinDate;
  final String gender;
  final String mcName;
  final String dob; // MM-dd
  final bool dlmMember;

  MCMember({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.isActive,
    required this.joinDate,
    required this.gender,
    required this.mcName,
    required this.dob,
    required this.dlmMember,
  });

  factory MCMember.fromMap(Map<String, dynamic> map) {
    return MCMember(
      id: map['id'].toString(),
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      isActive: map['isActive'].toString() == '1',
      joinDate: DateTime.parse(map['joinDate']),
      gender: map['gender'] ?? 'Other',
      mcName: map['mcName'] ?? '',
      dob: map['dob'] ?? '',
      dlmMember: map['dlm_member'].toString() == '1',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isActive': isActive ? '1' : '0',
      'joinDate': joinDate.toIso8601String(),
      'gender': gender,
      'mcName': mcName,
      'dob': dob,
      'dlm_member': dlmMember ? '1' : '0',
    };
  }
}
