import 'package:flutter/material.dart';
import '../services/profile_session_store.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialDateOfBirth;
  final String? initialGender;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    this.initialPhone = '',
    this.initialDateOfBirth = '',
    this.initialGender,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;

  static const _primaryColor = Color(0xFF1E88E5);
  static const _textColor = Color(0xFF111118);
  static const _grayText = Color(0xFF636388);
  static const _surfaceColor = Color(0xFFF5F7FA);

  static const List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _dobController = TextEditingController(text: widget.initialDateOfBirth);
    _selectedGender = widget.initialGender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _parseDob(widget.initialDateOfBirth) ??
        DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null && mounted) {
      final s = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dobController.text = s;
    }
  }

  DateTime? _parseDob(String? s) {
    if (s == null || s.length < 10) return null;
    final parts = s.split('-');
    if (parts.length < 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  void _save() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full name and email are required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    ProfileSessionStore.setFullName(name);
    ProfileSessionStore.setEmail(email);
    ProfileSessionStore.setPhone(_phoneController.text.trim());
    ProfileSessionStore.setDateOfBirth(_dobController.text.trim());
    ProfileSessionStore.setGender(_selectedGender ?? '');
    Navigator.of(context).pop(true);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _grayText),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Profile avatar with edit icon overlay
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Enter your full name'),
              style: const TextStyle(fontSize: 16, color: _textColor),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _inputDecoration('Enter your email'),
              style: const TextStyle(fontSize: 16, color: _textColor),
            ),
            const SizedBox(height: 20),
            _buildLabel('Phone Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Enter your phone number'),
              style: const TextStyle(fontSize: 16, color: _textColor),
            ),
            const SizedBox(height: 20),
            _buildLabel('Date of Birth'),
            const SizedBox(height: 8),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _inputDecoration('Select date').copyWith(
                suffixIcon: const Icon(Icons.calendar_today_rounded,
                    color: _grayText, size: 20),
              ),
              style: const TextStyle(fontSize: 16, color: _textColor),
            ),
            const SizedBox(height: 20),
            _buildLabel('Gender'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender != null &&
                          _genderOptions.contains(_selectedGender)
                      ? _selectedGender
                      : null,
                  hint: const Text(
                    'Select gender',
                    style: TextStyle(color: _grayText, fontSize: 16),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: _grayText),
                  items: _genderOptions
                      .map((s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 16,
                                color: _textColor,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _grayText,
      ),
    );
  }
}
