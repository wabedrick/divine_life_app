import 'package:flutter/material.dart';
import '../../models/mc_model.dart';
import '../../services/missional_community_service.dart';
import 'mc_form_screen.dart';

class MCManagementScreen extends StatefulWidget {
  const MCManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MCManagementScreenState createState() => _MCManagementScreenState();
}

class _MCManagementScreenState extends State<MCManagementScreen> {
  List<MissionalCommunity> mcs = [];
  List<MissionalCommunity> filteredMCs = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMCs();
    searchController.addListener(_filterMCs);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterMCs() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredMCs = List.from(mcs);
      });
    } else {
      setState(() {
        filteredMCs =
            mcs.where((mc) {
              return mc.name.toLowerCase().contains(query) ||
                  mc.location.toLowerCase().contains(query) ||
                  mc.leaderName.toLowerCase().contains(query);
            }).toList();
      });
    }
  }

  Future<void> _loadMCs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final mcList = await MissionalCommunityService.getAllMCs();
      setState(() {
        mcs = mcList;
        filteredMCs = List.from(mcs);
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
      builder: (context) => AlertDialog(
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
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );
      try {
        await MissionalCommunityService.deleteMC(mc.id!);
        if (!mounted) return;
        Navigator.of(context).pop(); // Remove loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missional community deleted successfully')),
        );
        _loadMCs();
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Remove loading indicator
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, location, or leader',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26.0),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _loadMCs,
                      child:
                          filteredMCs.isEmpty
                              ? Center(
                                child: Text('No missional communities found'),
                              )
                              : ListView.builder(
                                itemCount: filteredMCs.length,
                                itemBuilder: (context, index) {
                                  final mc = filteredMCs[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    onPressed:
                                                        () => _deleteMC(mc),
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
                                          Text(
                                            'Phone Number: ${mc.leaderPhoneNumber}',
                                          ),
                                          SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
          ),
        ],
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
