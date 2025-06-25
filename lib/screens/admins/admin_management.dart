import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../services/api_services.dart';
import 'admin_form_screen.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminManagementScreenState createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<Admin> admins = [];
  List<Admin> filteredUsers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdmins();
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredUsers = List.from(admins);
      });
    } else {
      setState(() {
        filteredUsers =
            admins.where((user) {
              return user.username.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.role.toLowerCase().contains(query);
            }).toList();
      });
    }
  }

  Future<void> _loadAdmins() async {
    setState(() {
      isLoading = true;
    });

    try {
      final adminList = await ApiService.getAdmins();
      setState(() {
        admins = adminList;
        filteredUsers = List.from(admins);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading admins: ${e.toString()}')),
      );
    }
  }

  void _deleteAdmin(Admin admin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${admin.username}?'),
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
        await ApiService.deleteAdmin(admin.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Admin deleted successfully')));
        _loadAdmins();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting admin: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Management'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by username, email, or role',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _loadAdmins,
                      child:
                          filteredUsers.isEmpty
                              ? Center(child: Text('No admins found'))
                              : ListView.builder(
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final admin = filteredUsers[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(admin.username),
                                      subtitle: Text(admin.email),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            admin.role.toUpperCase(),
                                            style: TextStyle(
                                              color:
                                                  admin.role == 'super_admin'
                                                      ? Colors.blue
                                                      : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 16),
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
                                                              AdminFormScreen(
                                                                admin: admin,
                                                              ),
                                                    ),
                                                  );
                                              if (result == true) {
                                                _loadAdmins();
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _deleteAdmin(admin),
                                          ),
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
            MaterialPageRoute(builder: (context) => AdminFormScreen()),
          );
          if (result == true) {
            _loadAdmins();
          }
        },
        tooltip: 'Add Admin',
        child: Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}
