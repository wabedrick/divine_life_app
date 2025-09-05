import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'mc_details.dart';

class MCsScreen extends StatefulWidget {
  const MCsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MCsScreenState createState() => _MCsScreenState();
}

class _MCsScreenState extends State<MCsScreen> {
  List<dynamic> _mcs = [];
  List<dynamic> _filteredMCs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMCs();
  }

  Future<void> _fetchMCs() async {
    final response = await http.get(
      Uri.parse(
  'http://127.0.0.1:8000/missionalCommunity/fetch_mcs.php',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _mcs = data['mcs'];
        _filteredMCs = _mcs; // Initialize filtered list with all MCs
      });
    }
  }

  void _filterMCs(String query) {
    setState(() {
      _filteredMCs =
          _mcs.where((mc) {
            final name = mc['mc_name'].toString().toLowerCase();
            final leader = mc['leader'].toString().toLowerCase();
            return name.contains(query.toLowerCase()) ||
                leader.contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Missional Communities'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search MC by name or the leader...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterMCs,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _filteredMCs.length,
              itemBuilder: (context, index) {
                final mc = _filteredMCs[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text(mc['mc_name']),
                    subtitle: Text('Leader: ${mc['leader']}'),
                    trailing: Text(
                      mc['leader_phoneNumber'] ?? 'No phone',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.0,
                      ),
                    ),
                    onTap: () {
                      // Navigate to the detailed MC screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MCDetailScreen(mc: mc),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
