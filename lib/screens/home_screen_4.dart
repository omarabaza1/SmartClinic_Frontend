import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_session_store.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'appointment_history_screen.dart';
import 'payment_history_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';

class HomeScreen4 extends StatefulWidget {
  const HomeScreen4({super.key});

  @override
  State<HomeScreen4> createState() => _HomeScreen4State();
}

class _HomeScreen4State extends State<HomeScreen4> {
  final _authService = AuthService();
  String _userName = 'Loading...';
  String _userEmail = '...';
  String _userPhone = '';
  String _userDateOfBirth = '';
  String? _userGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getFullName();
    final email = await _authService.getEmail();
    if (mounted) {
      setState(() {
        _userName = ProfileSessionStore.fullName ?? name ?? 'Guest User';
        _userEmail = ProfileSessionStore.email ?? email ?? 'guest@example.com';
        _userPhone = ProfileSessionStore.phone ?? '';
        _userDateOfBirth = ProfileSessionStore.dateOfBirth ?? '';
        _userGender = ProfileSessionStore.gender;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    const surfaceColor = Color(0xFFF5F7FA);

    return Container(
      color: surfaceColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 24),
          // User Info
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final updated = await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (context) => EditProfileScreen(
                                initialName: _userName,
                                initialEmail: _userEmail,
                                initialPhone: _userPhone,
                                initialDateOfBirth: _userDateOfBirth,
                                initialGender: _userGender,
                              ),
                            ),
                          );
                          if (mounted) {
                            _loadUserData();
                            if (updated == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated'),
                                  backgroundColor: Color(0xFF059669),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(_userName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 4),
                Text(_userEmail,
                    style: const TextStyle(color: grayText, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Clinical Activity
          const Text('Clinical Activity',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          _buildActivitySection([
            _buildProfileItem(
                Icons.calendar_today_rounded,
                'Appointment History',
                'Past visits & cancellations',
                const Color(0xFFEFF6FF),
                primaryColor,
                true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AppointmentHistoryScreen(),
                    ),
                  );
                }),
            _buildProfileItem(
                Icons.receipt_long_rounded,
                'Payment History',
                'Invoices & insurance',
                const Color(0xFFEFF6FF),
                primaryColor,
                false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const PaymentHistoryScreen(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 24),
          // Preferences
          const Text('Preferences',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          _buildActivitySection([
            _buildProfileItem(Icons.settings_rounded, 'Settings', null,
                const Color(0xFFF1F5F9), const Color(0xFF64748B), true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }),
            _buildProfileItem(Icons.help_outline_rounded, 'Help & Support',
                null, const Color(0xFFF1F5F9), const Color(0xFF64748B), false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 32),
          // Logout
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFEE2E2))),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 8),
                  Text('Log Out',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActivitySection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String? subtitle,
      Color bgColor, Color iconColor, bool showDivider,
      {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF111118))),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style:
                      const TextStyle(color: Color(0xFF636388), fontSize: 12))
              : null,
          trailing:
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          onTap: onTap,
        ),
        if (showDivider)
          const Padding(
              padding: EdgeInsets.only(left: 80, right: 20),
              child: Divider(height: 1, color: Color(0xFFF1F5F9))),
      ],
    );
  }
}
