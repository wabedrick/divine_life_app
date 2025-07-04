import 'package:flutter/material.dart';
import '../../../models/mc_member_model.dart';
import '../../../services/mc_member_service.dart';

class AddEditMemberScreen extends StatefulWidget {
  final MCMember? member;

  const AddEditMemberScreen({super.key, this.member});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditMemberScreenState createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isNewMember = false;
  bool _isActive = true;
  bool _isLoading = false;
  String? _selectedGender;
  bool _dlmMember = false;
  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      // Editing existing member
      _nameController.text = widget.member!.name;
      _phoneController.text = widget.member!.phone ?? '';
      _emailController.text = widget.member!.email ?? '';
      _isActive = widget.member!.isActive;
      _selectedGender = widget.member!.gender;
      _dobController.text = widget.member!.dob;
      _dlmMember = widget.member!.dlmMember;
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final memberData = MCMember(
        id: widget.member?.id ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        isActive: _isActive,
        gender: _selectedGender ?? 'Other',
        joinDate: widget.member?.joinDate ?? DateTime.now(),
        mcName: widget.member?.mcName ?? '', // TODO: Replace with actual MC name if available
        dob: _dobController.text.trim(),
        dlmMember: _dlmMember,
      );

      try {
        if (widget.member == null) {
          // Add new member
          await McMemberServices.addMember(memberData);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Member added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Update existing member
          await McMemberServices.updateMember(memberData);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Member updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving member: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;
    final title = isEditing ? 'Edit Member' : 'Add New Member';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Show confirmation dialog and delete
                _showDeleteDialog();
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter member name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Simple email validation
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        items:
                            _genderOptions
                                .map(
                                  (gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender, style: TextStyle(color: Colors.white)),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        maxLines: 2,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        maxLines: 3,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth (MM-DD)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.cake, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(now.year, 1, 1),
                            firstDate: DateTime(now.year, 1, 1),
                            lastDate: DateTime(now.year, 12, 31),
                            helpText: 'Select Birthday (Month and Day only)',
                            fieldLabelText: 'Birthday',
                            fieldHintText: 'MM-DD',
                            initialEntryMode: DatePickerEntryMode.calendar,
                          );
                          if (picked != null) {
                            _dobController.text = '${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select date of birth';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('DLM Member', style: TextStyle(color: Colors.white)),
                        subtitle: Text('Is this person a member of Divine Life Ministries?', style: TextStyle(color: Colors.white70)),
                        value: _dlmMember,
                        onChanged: (val) {
                          setState(() {
                            _dlmMember = val;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('New Member', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Mark if this person is a new addition to the group',
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: _isNewMember,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            _isNewMember = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text('Active Member', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Member is currently active in the ministry',
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: _isActive,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditing ? 'Update Member' : 'Add Member',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete Member', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete ${widget.member!.name}? This action cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await McMemberServices.deleteMember(widget.member!.id);
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Return to previous screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Member deleted successfully', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting member: ${e.toString()}', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
