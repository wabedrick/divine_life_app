// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../services/api_services.dart';

class AdminFormScreen extends StatefulWidget {
  final Admin? admin;

  const AdminFormScreen({super.key, this.admin});

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
    _isEditing = widget.admin != null;

    if (_isEditing) {
      _nameController.text = widget.admin!.username;
      _emailController.text = widget.admin!.email;
      _selectedRole = widget.admin!.role;
      _mcNameController.text = widget.admin!.mcName ?? '';
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
  // void _showSuccessDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (ctx) => AlertDialog(
  //           title: Text('Success', style: TextStyle(color: Colors.green)),
  //           content: Text(message),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(ctx).pop(); // Close dialog
  //                 Navigator.of(context).pop(true); // Return to previous screen
  //               },
  //               child: Text('Okay'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void _showSuccessDialog(String message) {
    // First, log the success message for debugging
    print('SUCCESS: $message');

    // Then show the dialog to the user
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Success'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _saveAdmin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    // Trim and validate inputs
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final mcName = _mcNameController.text.trim();

    print('Preparing to save admin: $name, $email, $mcName, $_selectedRole');

    // Additional input validations
    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    // Updated password validation to match PHP requirements (8 characters)
    if (!_isEditing && password.length < 8) {
      _showErrorDialog('Password must be at least 8 characters long');
      return;
    }

    // Validate medical center name is not empty
    if (mcName.isEmpty) {
      _showErrorDialog('Medical center name is required');
      return;
    }

    setState(() {
      _isLoading = true;
      print('Set loading state to true');
    });

    try {
      final adminData = Admin(
        id: _isEditing ? widget.admin?.id : null, // Include ID for editing
        username: name,
        email: email,
        role: _selectedRole,
        mcName: mcName,
        password: password.isNotEmpty ? password : null,
      );

      print('Admin data prepared: ${adminData.toJson()}');
      print('Is editing mode: $_isEditing');

      if (_isEditing) {
        if (widget.admin == null || widget.admin?.id == null) {
          print('Invalid admin ID for editing');
          throw Exception('Invalid admin data for editing');
        }

        print('Calling updateAdmin API...');
        final result = await ApiService.updateAdmin(adminData);
        print('API call completed successfully: ${result.toJson()}');

        // If we get here without exception, show success
        print('Showing success dialog');
        _showSuccessDialog('Admin updated successfully');

        // Wait briefly to ensure dialog is visible before potentially popping
        await Future.delayed(Duration(milliseconds: 1000));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true); // Return success
      } else {
        print('Calling createAdmin API...');
        await ApiService.createAdmin(adminData);
        print('Admin created successfully');
        _showSuccessDialog('Admin created successfully');

        // Wait briefly to ensure dialog is visible
        await Future.delayed(Duration(milliseconds: 1000));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true); // Return success
      }

      // Only pop if still mounted and operation was successful
      if (mounted) {
        print('Navigating back...');
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      // Enhanced error handling with detailed logging
      print('ERROR CAUGHT: ${e.toString()}');

      String errorMessage = 'Failed to save admin';

      if (e.toString().contains('MC not found')) {
        errorMessage = 'The specified MC was not found';
      } else if (e.toString().contains('Invalid email address')) {
        errorMessage = 'Please enter a valid email address';
      } else if (e.toString().contains('Password must be')) {
        errorMessage = 'Password must be at least 8 characters';
      } else if (e is NetworkException) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        // Include the actual error message
        errorMessage = 'Error: ${e.toString()}';
      }

      print('Showing error dialog: $errorMessage');
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          print('Set loading state to false');
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
