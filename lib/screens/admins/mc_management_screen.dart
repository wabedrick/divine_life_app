import 'package:divine_life_app/services/mc_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mc_model.dart';
import 'mc_form_screen.dart';

class MCManagementScreen extends StatefulWidget {
  const MCManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MCManagementScreenState createState() => _MCManagementScreenState();
}

class _MCManagementScreenState extends State<MCManagementScreen> {
  List<MissionalCommunity> mcs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMCs();
  }

  Future<void> _loadMCs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final mcList = await McServices.getMicroCommunities();
      setState(() {
        mcs = mcList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading missional communities: ${e.toString()}'),
        ),
      );
    }
  }

  void _deleteMC(MissionalCommunity mc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${mc.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('DELETE'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await McServices.deleteMissionalCommunity(mc.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missional community deleted successfully')),
        );
        _loadMCs();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting missional community: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MC Management'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadMCs,
                child:
                    mcs.isEmpty
                        ? Center(child: Text('No missionala communities found'))
                        : ListView.builder(
                          itemCount: mcs.length,
                          itemBuilder: (context, index) {
                            final mc = mcs[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            mc.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                MCFormScreen(
                                                                  mc: mc,
                                                                ),
                                                      ),
                                                    );
                                                if (result == true) {
                                                  _loadMCs();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => _deleteMC(mc),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text('Location: ${mc.location}'),
                                    SizedBox(height: 4),
                                    Text('Leader: ${mc.leaderName}'),
                                    SizedBox(height: 4),
                                    Text('Email: ${mc.leaderEmail}'),
                                    SizedBox(height: 4),
                                    Text(
                                      'Created: ${DateFormat('MMM d, yyyy').format(mc.createdAt)}',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MCFormScreen()),
          );
          if (result == true) {
            _loadMCs();
          }
        },
        tooltip: 'Add Missional Community',
        child: Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}
