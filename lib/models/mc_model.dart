class MissionalCommunity {
  final int? id;
  final String name;
  final String location;
  final String leaderName;
  final String leaderEmail;
  final DateTime createdAt;

  MissionalCommunity({
    this.id,
    required this.name,
    required this.location,
    required this.leaderName,
    required this.leaderEmail,
    required this.createdAt,
  });

  factory MissionalCommunity.fromJson(Map<String, dynamic> json) {
    return MissionalCommunity(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      leaderName: json['leader_name'],
      leaderEmail: json['leader_email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'location': location,
      'leader_name': leaderName,
      'leader_email': leaderEmail,
    };

    if (id != null) data['id'] = id;

    return data;
  }
}
