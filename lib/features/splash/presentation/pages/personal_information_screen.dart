import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth. instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user. email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (! _formKey.currentState! .validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance. currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController. text. trim());
        await user.reload();

        if (mounted) {
          ScaffoldMessenger. of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully! '),
              backgroundColor:  Color(0xFF4CAF50),
            ),
          );
          setState(() {
            _hasChanges = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors. white,
        elevation: 0,
        leading: IconButton(
          icon:  const Icon(Icons. arrow_back_ios, color: Color(0xFF0D121F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Color(0xFF0D121F),
            fontSize: 18,
            fontWeight:  FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key:  _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Picture
              Stack(
                children:  [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 3,
                      ),
                    ),
                    child: user?. photoURL != null
                        ?  ClipOval(
                      child: Image.network(
                        user! .photoURL!,
                        fit:  BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color:  Color(0xFF6B7FD7),
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.person,
                      size:  60,
                      color: Color(0xFF6B7FD7),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger. of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo upload coming soon!'),
                              backgroundColor: Color(0xFFD4AF37),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Name Field
              _buildTextField(
                controller:  _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                onChanged: (_) {
                  setState(() {
                    _hasChanges = true;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field (Read-only)
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                readOnly: true,
                suffixIcon: Icons.lock_outline,
              ),
              const SizedBox(height:  12),

              Text(
                'Email cannot be changed for security reasons',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || ! _hasChanges ?  null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D121F),
                    foregroundColor: Colors. white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child:  _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color:  Colors.white,
                    ),
                  )
                      :  const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:  FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    IconData? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius:  10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(
          color: readOnly ? Colors.grey. shade600 : const Color(0xFF0D121F),
        ),
        decoration:  InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFD4AF37),
          ),
          suffixIcon: suffixIcon != null
              ? Icon(
            suffixIcon,
            color: Colors.grey.shade400,
            size: 20,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide. none,
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical:  16,
          ),
        ),
      ),
    );
  }
}