// models/user_model.dart
class User {
  final String id;
  final String username;
  final String email;
  final String? missionalCommunity;
  final String? userPassword;
  final String? role;
  final String? mcId;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.missionalCommunity,
    this.userPassword,
    this.role,
    this.mcId,
  });

  /// Create a User object from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      missionalCommunity: json['missional_community'],
      userPassword: json['user_password'],
      role: json['role'],
      mcId: json['mc_id']?.toString(),
    );
  }

  /// Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'missional_community': missionalCommunity,
      'user_password': userPassword,
      'role': role,
      'mc_id': mcId,
    };
  }

  /// Create a copy of this User with modified fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? missionalCommunity,
    String? userPassword,
    String? role,
    String? mcId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      missionalCommunity: missionalCommunity ?? this.missionalCommunity,
      userPassword: userPassword ?? this.userPassword,
      role: role ?? this.role,
      mcId: mcId ?? this.mcId,
    );
  }
}
