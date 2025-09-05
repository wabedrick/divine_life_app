import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class RoleGuard extends StatefulWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuard({required this.allowedRoles, required this.child, super.key});

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  bool _allowed = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final auth = AuthService();
    final token = await auth.getToken();
    if (token == null) {
      // not logged in
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final rolesCsv = prefs.getString('role') ?? '';
    final roles = rolesCsv.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty).toList();
    final allowed = widget.allowedRoles.map((r) => r.toLowerCase()).toList();
    final intersects = roles.any((r) => allowed.contains(r));

    setState(() {
      _allowed = intersects;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_allowed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Forbidden')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text('You do not have permission to view this page.', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    // logout and send to login
                    await AuthService().logout();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  },
                  child: const Text('Return to Login'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
