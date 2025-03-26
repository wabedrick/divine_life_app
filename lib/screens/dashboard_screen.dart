import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'mcs_screen.dart';
import 'user_event_screen.dart';

class DashboardScreen extends StatelessWidget {
  final User user;
  final AuthService _authService = AuthService();

  DashboardScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.logout();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divine Life Ministries'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        // The actions property is used to add buttons to the app bar
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () => _logout(context),
        //     tooltip: 'Logout',
        //   ),
        // ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  // Build the Navigation Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade800),
            accountName: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              user.email,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
              child:
                  user.profileImage == null
                      ? Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      )
                      : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Navigate to Profile Screen
              Navigator.pop(context);
              //Implement navigation to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to Settings Screen
              Navigator.pop(context);
              // Implement navigation to settings screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // Build the Dashboard Body
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User welcome card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage:
                          user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null,
                      child:
                          user.profileImage == null
                              ? Text(
                                user.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user.username[0].toUpperCase()}${user.username.substring(1)}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Text(
                          //   'Role: ${user.role.toUpperCase()}',
                          //   style: TextStyle(
                          //     color: Colors.grey[700],
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Church Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),

          // Dashboard grid
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildDashboardCard(
                  context,
                  icon: Icons.chat,
                  title: 'Chat',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to Chat Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatScreen(
                              user: User(
                                username: user.username,
                                email: user.email,
                                profileImage: user.profileImage,
                                role: user.role,
                                password: user.password,
                                mc: user.mc,
                              ),
                            ),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.people,
                  title: 'MCs',
                  color: Colors.green,
                  onTap: () {
                    // Navigate to Missional Community Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MCsScreen()),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.analytics,
                  title: 'Retention',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to Retention Screen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.library_books,
                  title: 'Sermons',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to Sermons Screen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.event,
                  title: 'Events',
                  color: Colors.red,
                  onTap: () {
                    // Navigate to Events Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserEventScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.more_horiz,
                  title: 'More',
                  color: Colors.teal,
                  onTap: () {
                    // Navigate to More Screen
                  },
                ),
              ],
            ),
          ),

          // Recent announcements section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Recent Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),

          // Announcements list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: 3, // Just showing 3 sample announcements
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.announcement,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  title: Text('Announcement ${index + 1}'),
                  subtitle: Text(
                    'This is a sample announcement description. Tap to read more.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to announcement details
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Build a Dashboard Card
  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: color),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
