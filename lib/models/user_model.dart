// models/user_model.dart
class User {
  // final int id;
  final String username;
  final String email;
  final String? profileImage;
  final String role;
  final Map<String, dynamic>? additionalInfo;
  final String? password;
  final String mc;

  User({
    // this.id,
    required this.username,
    required this.email,
    this.profileImage,
    required this.role,
    this.additionalInfo,
    required this.password,
    required this.mc,
  });

  /// Create a User object from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // id: json['id'] is String ? int.parse(json['id']) : json['id'],
      username: json['username'],
      email: json['email'],
      mc: json['mc'] ?? json['mc'] ?? '',
      profileImage: json['profile_image'] ?? json['profileImage'],
      role: json['role'] ?? 'member',
      additionalInfo: json['additional_info'] ?? json['additionalInfo'],
      // createdAt:
      //     json['created_at'] != null
      //         ? DateTime.parse(json['created_at'])
      //         : (json['createdAt'] != null
      //             ? DateTime.parse(json['createdAt'])
      //             : DateTime.now()),
      password: json['password'],
    );
  }

  get id => null;

  /// Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
      'role': role,
      'additional_info': additionalInfo,
      'password': password,
      'mc': mc,
    };
  }

  /// Create a copy of this User with modified fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? profileImage,
    String? role,
    Map<String, dynamic>? additionalInfo,
    String? mc,
    String? password,
  }) {
    return User(
      // id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      password: password ?? this.password,
      mc: mc ?? this.mc,
    );
  }
}
