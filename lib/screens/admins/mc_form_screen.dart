// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../models/mc_model.dart';
import '../../services/missional_community_service.dart';
import '../../utils/app_colors.dart';

class MCFormScreen extends StatefulWidget {
  final MissionalCommunity? mc;

  const MCFormScreen({super.key, this.mc});

  @override
  // ignore: library_private_types_in_public_api
  _MCFormScreenState createState() => _MCFormScreenState();
}

class _MCFormScreenState extends State<MCFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _leaderNameController = TextEditingController();
  final _leaderPhoneNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.mc != null;

    if (_isEditing) {
      _nameController.text = widget.mc!.name;
      _locationController.text = widget.mc!.location;
      _leaderNameController.text = widget.mc!.leaderName;
      _leaderPhoneNumberController.text = widget.mc!.leaderPhoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _leaderNameController.dispose();
    _leaderPhoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveMC() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mcData = MissionalCommunity(
        id: _isEditing ? widget.mc!.id : null,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        leaderName: _leaderNameController.text.trim(),
        leaderPhoneNumber: _leaderPhoneNumberController.text.trim(),
      );

      // final mcServices = McServices();
      dynamic result;

      if (_isEditing) {
        try {
          final result = await MissionalCommunityService.updateMC(mcData);
          if (result['success']) {
            _showSuccessMessage(
              result['message'] ?? 'Missional community updated successfully',
            );
            if (mounted) Navigator.of(context).pop(true);
            return;
          } else {
            _showErrorMessage(result['message'] ?? 'Failed to update');
          }
        } catch (e) {
          _showErrorMessage('Failed to update: ${e.toString()}');
        }
      } else {
        result = await MissionalCommunityService.createMC(mcData);
      }

      // Handle the result with user-friendly messaging
      if (result['success']) {
        _showSuccessMessage(
          result['message'] ??
              (_isEditing
                  ? 'Missional community updated successfully'
                  : 'Missional community created successfully'),
        );
        if (mounted) Navigator.pop(context, true);
        return;
      } else {
        _showErrorMessage(result['message'] ?? 'An unexpected error occurred');
      }
    } catch (e) {
      _showErrorMessage('Error: ${_getErrorMessage(e)}');
    } finally {
      // Ensure loading state is reset
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to extract meaningful error messages
  String _getErrorMessage(dynamic error) {
    String errorMessage = error.toString();

    // Common error message parsing
    if (errorMessage.contains('Failed to connect')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorMessage.contains('already exists')) {
      return 'A Missional Community with this name already exists.';
    }

    return errorMessage.length > 100
        ? 'An unexpected error occurred. Please try again.'
        : errorMessage;
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Missional Community' : 'Add Missional Community',
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: AppColors.dark,
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
                  labelText: 'MC Name',
                  prefixIcon: Icon(Icons.group, color: Colors.white),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Please enter MC name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _leaderNameController,
                decoration: InputDecoration(
                  labelText: 'Leader Name',
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Please enter leader name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on, color: Colors.white),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _leaderPhoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Leader Phone Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Please enter leader phone number' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMC,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.accent,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Update Missional Community' : 'Create Missional Community',
                        style: TextStyle(color: AppColors.primary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
