// lib/models/admin.dart
class Admin {
  final int? id;
  final String name;
  final String email;
  final String role; // "super_admin" or "admin"
  final String? password; // Only used when creating/updating

  Admin({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'role': role,
    };

    if (id != null) data['id'] = id;
    if (password != null) data['password'] = password;

    return data;
  }
}
