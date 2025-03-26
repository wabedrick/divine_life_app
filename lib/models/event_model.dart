class Event {
  final int id;
  final String name;
  final DateTime date;
  final String information;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.information,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      information: json['information'],
    );
  }
}
