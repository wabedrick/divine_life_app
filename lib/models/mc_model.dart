class MissionalCommunity {
  final int? id;
  final String name;
  final String location;
  final String leaderName;
  final String leaderPhoneNumber;
  // final DateTime createdAt;

  MissionalCommunity({
    this.id,
    required this.name,
    required this.location,
    required this.leaderName,
    required this.leaderPhoneNumber,
    // required this.createdAt,
  });

  factory MissionalCommunity.fromJson(Map<String, dynamic> json) {
    return MissionalCommunity(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['mc_name'],
      location: json['mc_location'],
      leaderName: json['leader'],
      leaderPhoneNumber: json['leader_phoneNumber'],
      // createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'mc_name': name,
      'mc_location': location,
      'leader': leaderName,
      'leader_phoneNumber': leaderPhoneNumber,
    };

    if (id != null) data['id'] = id;

    return data;
  }
}
