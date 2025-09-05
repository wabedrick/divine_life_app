// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';

class EventService {
  final String apiUrl = "http://127.0.0.1:8000/events/";

  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse('${apiUrl}read_events.php'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> createEvent(Event event) async {
    final response = await http.post(
      Uri.parse('${apiUrl}create_event.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': event.name,
        'date': event.date.toIso8601String(),
        'information': event.information,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to create event: ${response.body}");
    }
  }

  Future<void> updateEvent(Event event) async {
    final response = await http.post(
      Uri.parse('${apiUrl}update_event.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': event.id,
        'name': event.name,
        'date': event.date.toIso8601String(),
        'information': event.information,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.post(
      Uri.parse('${apiUrl}delete_event.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'id': id}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }
}
