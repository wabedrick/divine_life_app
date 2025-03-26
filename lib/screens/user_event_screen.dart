import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class UserEventScreen extends StatefulWidget {
  const UserEventScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserEventScreenState createState() => _UserEventScreenState();
}

class _UserEventScreenState extends State<UserEventScreen> {
  late Future<List<Event>> futureEvents;
  final EventService eventService = EventService();

  @override
  void initState() {
    super.initState();
    futureEvents = eventService.getEvents();
  }

  void _refreshEvents() {
    setState(() {
      futureEvents = eventService.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upcoming Events')),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No upcoming events.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Event event = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Date: ${event.date.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Details: ${event.information}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshEvents,
        tooltip: 'Refresh Events',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
