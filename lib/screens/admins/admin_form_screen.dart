import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_services.dart';

class AdminFormScreen extends StatefulWidget {
  final User? user;

  const AdminFormScreen({super.key, this.user});

  @override
  // ignore: library_private_types_in_public_api
  _AdminFormScreenState createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mcNameController = TextEditingController();

  String _selectedRole = 'admin';
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;

    if (_isEditing) {
      _nameController.text = widget.user!.username;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
      _mcNameController.text = widget.user!.mc;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mcNameController.dispose();
    super.dispose();
  }

  // Improved error handling method
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Error', style: TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Okay'),
              ),
            ],
          ),
    );
  }

  // Improved success handling method
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Success', style: TextStyle(color: Colors.green)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Return to previous screen
                },
                child: Text('Okay'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveAdmin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Trim and validate inputs
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final mcName = _mcNameController.text.trim();

    // Additional input validations
    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    if (!_isEditing && password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adminData = User(
        username: name,
        email: email,
        role: _selectedRole,
        password: password.isNotEmpty ? password : null,
        mc: mcName,
      );

      if (_isEditing) {
        await ApiService.updateAdmin(adminData);
        _showSuccessDialog('Admin updated successfully');
      } else {
        await ApiService.createAdmin(adminData);
        _showSuccessDialog('Admin created successfully');
      }
    } catch (e) {
      // More specific error handling
      String errorMessage = 'An unexpected error occurred';
      if (e is ApiException) {
        errorMessage = e.message;
      } else if (e is NetworkException) {
        errorMessage = 'Network error. Please check your connection.';
      }

      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Email validation method
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Admin' : 'Add Admin'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!_isValidEmail(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText:
                      _isEditing ? 'New Password (optional)' : 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Please enter a password';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _mcNameController,
                decoration: InputDecoration(
                  labelText: 'MC Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your MC Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                value: _selectedRole,
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'super admin',
                    child: Text('Super Admin'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAdmin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          _isEditing ? 'Update Admin' : 'Create Admin',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom exception classes for more specific error handling
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
