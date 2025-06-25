// mc_member_model.dart
class MCMember {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime joinDate;
  final String gender;

  MCMember({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.isActive,
    required this.joinDate,
    required this.gender,
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
    };
  }
}
