class Admin {
  final int? id;
  final String username;
  final String email;
  final String role; // "super_admin" or "admin"
  final String? password; // Only used when creating/updating
  final String? mcName; // Only used when creating/updating

  Admin({
    this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.mcName,
    this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      mcName: json['mc_name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'mc_name':
          mcName, // FIXED: Changed key from 'mc' to 'mc_name' to match PHP expectation
      'role': role,
    };

    if (id != null) data['id'] = id;
    if (password != null) data['password'] = password;

    return data;
  }
}
