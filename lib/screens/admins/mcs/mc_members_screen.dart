import 'package:flutter/material.dart';
import '../../../models/mc_member_model.dart';
import '../../../services/mc_member_service.dart';
import 'add_edit_member_screen.dart';

class MCMembersScreen extends StatefulWidget {
  const MCMembersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MCMembersScreenState createState() => _MCMembersScreenState();
}

class _MCMembersScreenState extends State<MCMembersScreen> {
  List<MCMember> members = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final membersResponse = await McMemberServices.getMembers();
      setState(() {
        members = membersResponse;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading members: ${e.toString()}')),
      );
    }
  }

  void _filterMembers(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  List<MCMember> get filteredMembers {
    if (searchQuery.isEmpty) {
      return members;
    }
    return members.where((member) {
      return member.name.toLowerCase().contains(searchQuery) ||
          (member.phone != null && member.phone!.contains(searchQuery)) ||
          (member.email != null &&
              member.email!.toLowerCase().contains(searchQuery));
    }).toList();
  }

  Future<void> _confirmDelete(MCMember member) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Member'),
            content: Text(
              'Are you sure you want to delete ${member.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (result == true) {
      _deleteMember(member);
    }
  }

  Future<void> _deleteMember(MCMember member) async {
    try {
      await McMemberServices.deleteMember(member.id);
      _loadMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.name} has been deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting member: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MC Members'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMembers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterMembers,
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredMembers.isEmpty
                    ? Center(child: Text('No members found'))
                    : ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                member.name.isNotEmpty
                                    ? member.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                            title: Text(member.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (member.phone != null &&
                                    member.phone!.isNotEmpty)
                                  Text('📱 ${member.phone}'),
                                if (member.email != null &&
                                    member.email!.isNotEmpty)
                                  Text('✉️ ${member.email}'),
                              ],
                            ),
                            isThreeLine:
                                member.phone != null && member.email != null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddEditMemberScreen(
                                              member: member,
                                            ),
                                      ),
                                    ).then((_) => _loadMembers());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(member),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditMemberScreen()),
          ).then((_) => _loadMembers());
        },
        backgroundColor: Colors.green,
        tooltip: 'Add Member',
        child: Icon(Icons.person_add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
