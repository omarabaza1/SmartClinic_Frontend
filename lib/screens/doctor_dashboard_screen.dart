import 'package:flutter/material.dart';

import '../widgets/dashboard_action_card.dart';
import '../widgets/dashboard_header.dart';
import 'doctor_availability_screen.dart';
import 'home_screen_1.dart';
import 'messages_screen.dart';

/// Doctor dashboard screen using the same visual style
/// as the patient dashboard (HomeScreen3).
class DoctorDashboardScreen extends StatefulWidget {
  final String doctorName;
  final ImageProvider avatarImage;
  final VoidCallback onNotificationTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onAvatarTap;
  /// Opens the Bookings tab (doctor patient-bookings inbox).
  final VoidCallback? onPatientBookingsTab;

  const DoctorDashboardScreen({
    super.key,
    required this.doctorName,
    required this.avatarImage,
    required this.onNotificationTap,
    this.onLogoutTap,
    this.onAvatarTap,
    this.onPatientBookingsTab,
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _hoverAppointments = false;
  bool _hoverBookings = false;
  bool _hoverMessages = false;
  bool _hoverAvailability = false;

  @override
  Widget build(BuildContext context) {
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DashboardHeader(
        username: widget.doctorName,
        avatarImage: widget.avatarImage,
        onNotificationTap: widget.onNotificationTap,
        onLogoutTap: widget.onLogoutTap,
        onAvatarTap: widget.onAvatarTap,
        greeting: 'Good day,',
        // notificationCount can be wired in when navigation is connected
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                left: BorderSide(color: Color(0xFF1E88E5), width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111118),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review your schedule and manage patient bookings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF636388),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What would you like to manage?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverAppointments = true),
                  onExit: (_) => setState(() => _hoverAppointments = false),
                  child: DashboardActionCard(
                    icon: Icons.event_note_rounded,
                    title: 'View Todays Appointments',
                    subtitle: 'Today',
                    gradientColors: const [
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                    ],
                    isHovered: _hoverAppointments,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const HomeScreen1(
                            todayOnlyView: true,
                            showDoctorAppBar: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverBookings = true),
                  onExit: (_) => setState(() => _hoverBookings = false),
                  child: DashboardActionCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Patient Bookings',
                    subtitle: 'Bookings',
                    gradientColors: const [
                      Color(0xFF10B981),
                      Color(0xFF059669),
                    ],
                    isHovered: _hoverBookings,
                    onTap: () {
                      widget.onPatientBookingsTab?.call();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverMessages = true),
                  onExit: (_) => setState(() => _hoverMessages = false),
                  child: DashboardActionCard(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Messages',
                    subtitle: 'Patient chats',
                    gradientColors: const [
                      Color(0xFF0EA5E9),
                      Color(0xFF0284C7),
                    ],
                    isHovered: _hoverMessages,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const MessagesScreen(
                                isDoctor: true,
                                registerOverlayTabBadge: true,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverAvailability = true),
                  onExit: (_) => setState(() => _hoverAvailability = false),
                  child: DashboardActionCard(
                    icon: Icons.schedule_rounded,
                    title: 'Availability',
                    subtitle: 'Schedule',
                    gradientColors: const [
                      Color(0xFFF97316),
                      Color(0xFFEA580C),
                    ],
                    isHovered: _hoverAvailability,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const DoctorAvailabilityScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

