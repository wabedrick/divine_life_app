import 'package:flutter/material.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'admins/admin_dashboard.dart';
import 'admins/super_admin_dashboard.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart' as validators;
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../utils/app_colors.dart';
import 'admins/mc_leader_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login process with proper error handling
  Future<void> _login() async {
    try {
      // Send a POST request to the login endpoint
      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:8000/users/login.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      // Debugging: Print the raw response
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);

        // Check if the login was successful
        if (data['status'] == 'success') {
          // Save user details and token (e.g., using shared_preferences)
          final username = data['username'];
          final mcId =
              int.tryParse(data['mc_id'].toString()) ??
              0; // Convert mc_id to int
          final email = data['email'];
          final token = data['token'];

          // Example: Save user details to shared_preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', username);
          prefs.setInt(
            'mc_id',
            mcId,
          ); // Use 0 as a default value if mcId is null
          prefs.setString('email', email);
          prefs.setString('token', token);

          // Show a success message
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));

          if ((data['role']?.toLowerCase() ?? '') == 'super admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => SuperAdminDashboard()),
            );
          } else if ((data['role']?.toLowerCase() ?? '') == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => AdminDashboard()),
            );
          } else if ((data['role']?.toLowerCase() ?? '') == 'mc_leader' || (data['role']?.toLowerCase() ?? '') == 'mc leader') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MCLeaderDashboard()),
            );
          } else {
            // Handle other roles
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DashboardScreen(
                      user: User(
                        id: '', // Provide a placeholder or actual id if available
                        username: username,
                        email: email,
                        role: '',
                        userPassword: '',
                        missionalCommunity: '',
                      ),
                    ),
              ),
            );
          }
        } else {
          // Show an error message
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        // Handle server errors
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server')),
        );
      }
    } catch (e) {
      // Handle any exceptions (e.g., network errors)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  // void _showErrorMessage(String message) {
  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red.shade700,
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  void _navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController emailController = TextEditingController();

        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address to receive password reset instructions.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Implement password reset functionality here
                if (emailController.text.isNotEmpty &&
                    validators.Validators.isValidEmail(emailController.text)) {
                  _authService.requestPasswordReset(emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password reset instructions sent to your email.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('SUBMIT'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child: const Text(
              'Login Here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26),
            ),
          ),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.accent,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo or Church Logo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Center(
                        child: Image.asset(
                          'assets/dlmi-logo.png',
                          height: 140,
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.validateUsername(value),
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.white),
                      obscureText: _obscurePassword,
                      validator: (value) => Validators.validatePassword(value),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    CustomButton(onPressed: _login, text: 'LOGIN', color: AppColors.accent, textColor: AppColors.primary),
                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?', style: TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: _navigateToRegisterScreen,
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
