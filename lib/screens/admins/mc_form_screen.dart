// lib/screens/super_admin/mc_form_screen.dart
import 'package:divine_life_app/services/mc_services.dart';
import 'package:flutter/material.dart';
import '../../models/mc_model.dart';

class MCFormScreen extends StatefulWidget {
  final MissionalCommunity? mc;

  // ignore: use_key_in_widget_constructors
  const MCFormScreen({this.mc});

  @override
  // ignore: library_private_types_in_public_api
  _MCFormScreenState createState() => _MCFormScreenState();
}

class _MCFormScreenState extends State<MCFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _leaderNameController = TextEditingController();
  final _leaderEmailController = TextEditingController();
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
      _leaderEmailController.text = widget.mc!.leaderEmail;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _leaderNameController.dispose();
    _leaderEmailController.dispose();
    super.dispose();
  }

  Future<void> _saveMC() async {
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
        leaderEmail: _leaderEmailController.text.trim(),
        createdAt: _isEditing ? widget.mc!.createdAt : DateTime.now(),
      );

      if (_isEditing) {
        await McServices.updateMissionalCommunity(mcData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missional community updated successfully')),
        );
      } else {
        await McServices.createMissionalCommunity(mcData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missional community created successfully')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
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
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _leaderNameController,
                decoration: InputDecoration(
                  labelText: 'Leader Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter leader name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _leaderEmailController,
                decoration: InputDecoration(
                  labelText: 'Leader Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter leader email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMC,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          _isEditing
                              ? 'Update Missional Community'
                              : 'Create Missional Community',
                          style: TextStyle(color: Colors.black),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
