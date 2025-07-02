import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_services.dart';
import '../../services/missional_community_service.dart';
import '../../models/mc_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  bool isLoading = true;
  List<MissionalCommunity> mcs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadMCs();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(users);
      } else {
        filteredUsers = users.where((user) =>
          user.username.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.missionalCommunity?.toLowerCase().contains(query) ?? false) ||
          (user.role?.toLowerCase().contains(query) ?? false)
        ).toList();
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      users = await ApiService.getUsers();
      filteredUsers = List.from(users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadMCs() async {
    try {
      final mcList = await MissionalCommunityService.getAllMCs();
      setState(() {
        mcs = mcList;
      });
    } catch (e) {
      // Optionally show error
    }
  }

  Future<void> _promoteToMCLeader(User user) async {
    if (user.role == 'member') {
      await ApiService.promoteToMCLeader(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.username} promoted to MC Leader!')),
      );
    } else if (user.role == 'mc_leader') {
      await ApiService.demoteToMember(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.username} demoted to Member.')),
      );
    }
    _loadUsers();
  }

  Future<void> _showUserForm({User? user}) async {
    final isEditing = user != null;
    final _formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    String? selectedMcId = user?.mcId;
    String? selectedMcName = user?.missionalCommunity;
    String? selectedLeaderName;
    String _role = user?.role ?? 'member';

    if (selectedMcId != null) {
      final selectedMc = mcs.firstWhere(
        (mc) => mc.id?.toString() == selectedMcId,
        orElse: () => mcs.isNotEmpty ? mcs.first : MissionalCommunity(id: null, name: '', location: '', leaderName: '', leaderPhoneNumber: ''),
      );
      selectedLeaderName = selectedMc.leaderName;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit User' : 'Add User'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                ),
                TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedMcId,
                  dropdownColor: Colors.blueGrey[900],
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Missional Community',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  items: mcs.map((mc) => DropdownMenuItem(
                    value: mc.id?.toString(),
                    child: Text(mc.name, style: TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedMcId = val;
                      final selectedMc = mcs.firstWhere((mc) => mc.id?.toString() == val);
                      selectedMcName = selectedMc.name;
                      selectedLeaderName = selectedMc.leaderName;
                    });
                  },
                  validator: (v) => v == null || v.isEmpty ? 'Select MC' : null,
                ),
                if (selectedLeaderName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'MC Leader: [1m$selectedLeaderName',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (!isEditing)
                  TextFormField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                  ),
                DropdownButtonFormField<String>(
                  value: _role,
                  dropdownColor: Colors.blueGrey[900],
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  items: ['member', 'mc_leader']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (val) => setState(() => _role = val ?? 'member'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() != true) return;
              final newUser = User(
                id: user?.id ?? '',
                username: usernameController.text.trim(),
                email: emailController.text.trim(),
                missionalCommunity: selectedMcName,
                userPassword: emailController.text.trim(),
                role: _role,
                mcId: selectedMcId,
              );
              try {
                if (isEditing) {
                  await ApiService.updateUser(newUser);
                } else {
                  await ApiService.addUser(newUser);
                }
                Navigator.pop(context);
                _loadUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: $e')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deleteUser(user.id);
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _editUser(User user) async {
    await _showUserForm(user: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by username, email, MC, or role',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, i) {
                        final user = filteredUsers[i];
                        return Card(
                          color: Colors.blueGrey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(user.username, style: TextStyle(color: Colors.white)),
                            subtitle: Text('${user.email} (${user.role})', style: TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (user.role == 'member' || user.role == 'mc_leader')
                                  IconButton(
                                    icon: Icon(
                                      user.role == 'member' ? Icons.upgrade : Icons.arrow_downward,
                                      color: user.role == 'member' ? Colors.green : Colors.orange,
                                    ),
                                    tooltip: user.role == 'member' ? 'Promote to MC Leader' : 'Demote to Member',
                                    onPressed: () => _promoteToMCLeader(user),
                                  ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Edit User',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserFormScreen(
                                        user: user,
                                        mcs: mcs,
                                        onSave: (updatedUser) async {
                                          await ApiService.updateUser(updatedUser);
                                          Navigator.pop(context);
                                          _loadUsers();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Delete User',
                                  onPressed: () => _deleteUser(user),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserFormScreen(
              mcs: mcs,
              onSave: (newUser) async {
                await ApiService.addUser(newUser);
                Navigator.pop(context);
                _loadUsers();
              },
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, size: 32),
        tooltip: 'Add User',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  final User? user;
  final List<MissionalCommunity> mcs;
  final Function(User) onSave;
  const UserFormScreen({Key? key, this.user, required this.mcs, required this.onSave}) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedMcId;
  String? _selectedMcName;
  String? _selectedLeaderName;
  String _role = 'mc_leader';
  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedMcId = widget.user?.mcId;
    _selectedMcName = widget.user?.missionalCommunity;
    if (widget.user != null && ['member', 'mc_leader'].contains(widget.user!.role)) {
      _role = widget.user!.role!;
    } else {
      _role = 'mc_leader';
    }
    if (_selectedMcId != null) {
      final selectedMc = widget.mcs.firstWhere(
        (mc) => mc.id?.toString() == _selectedMcId,
        orElse: () => widget.mcs.isNotEmpty ? widget.mcs.first : MissionalCommunity(id: null, name: '', location: '', leaderName: '', leaderPhoneNumber: ''),
      );
      _selectedLeaderName = selectedMc.leaderName;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit MC Leader' : 'Add MC Leader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMcId,
                dropdownColor: Colors.blueGrey[900],
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Missional Community',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                items: widget.mcs.map((mc) => DropdownMenuItem(
                  value: mc.id?.toString(),
                  child: Text(mc.name, style: TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMcId = val;
                    final selectedMc = widget.mcs.firstWhere((mc) => mc.id?.toString() == val);
                    _selectedMcName = selectedMc.name;
                    _selectedLeaderName = selectedMc.leaderName;
                  });
                },
                validator: (v) => v == null || v.isEmpty ? 'Select MC' : null,
              ),
              if (_selectedLeaderName?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'MC Leader: [1m$_selectedLeaderName',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 16),
              if (!isEditing)
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                ),
              if (!isEditing) SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                dropdownColor: Colors.blueGrey[900],
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                items: ['member', 'mc_leader']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (val) => setState(() => _role = val ?? 'mc_leader'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) return;
                  final newUser = User(
                    id: widget.user?.id ?? '',
                    username: _usernameController.text.trim(),
                    email: _emailController.text.trim(),
                    missionalCommunity: _selectedMcName,
                    userPassword: _passwordController.text.trim(),
                    role: _role,
                    mcId: _selectedMcId,
                  );
                  widget.onSave(newUser);
                },
                child: Text(isEditing ? 'Update' : 'Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 