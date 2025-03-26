import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_services.dart';
import 'admin_form_screen.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminManagementScreenState createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      isLoading = true;
    });

    try {
      final adminList = await ApiService.getAdmins();
      setState(() {
        users = adminList;
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

  void _deleteAdmin(User admin) async {
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
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadAdmins,
                child:
                    users.isEmpty
                        ? Center(child: Text('No admins found'))
                        : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final admin = users[index];
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
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => AdminFormScreen(
                                                  user: admin,
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
                                      onPressed: () => _deleteAdmin(admin),
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
