import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'mcs_screen.dart';
import 'user_event_screen.dart';
import '../utils/app_colors.dart';

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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.accent,
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
            decoration: BoxDecoration(color: AppColors.primary),
            accountName: Text(
              user.username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accent),
            ),
            accountEmail: Text(
              user.email,
              style: TextStyle(fontSize: 14, color: AppColors.accent),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(
                user.username.isNotEmpty
                    ? user.username[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
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
              color: AppColors.secondary.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.username[0].toUpperCase()}${user.username.substring(1)}!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                color: AppColors.primary,
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
                  color: AppColors.primary,
                  onTap: () {
                    // Navigate to Chat Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatScreen(
                              user: User(
                                id: '',
                                username: user.username,
                                email: user.email,
                                role: user.role,
                                userPassword: '',
                                missionalCommunity: '',
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
                  color: AppColors.secondary,
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
                  color: AppColors.accent,
                  onTap: () {
                    // Navigate to Retention Screen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.library_books,
                  title: 'Sermons',
                  color: AppColors.primary.withOpacity(0.7),
                  onTap: () {
                    // Navigate to Sermons Screen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.event,
                  title: 'Events',
                  color: AppColors.dark,
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
                  color: AppColors.secondary,
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
                color: AppColors.primary,
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
