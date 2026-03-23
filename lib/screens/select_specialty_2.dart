import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import 'all_specialties_screen.dart';
import 'map_location_screen.dart';
import 'select_specialty_3.dart';

class SelectSpecialty2Screen extends StatefulWidget {
  const SelectSpecialty2Screen({super.key});

  @override
  State<SelectSpecialty2Screen> createState() => _SelectSpecialty2ScreenState();
}

class _SelectSpecialty2ScreenState extends State<SelectSpecialty2Screen> {
  static const List<String> _locations = [
    'Cairo, Egypt',
    'Alexandria, Egypt',
    'Giza, Egypt',
    'Mansoura, Egypt',
    'Port Said, Egypt',
  ];

  String _selectedLocation = _locations.first;
  final _appointmentService = AppointmentService();
  int _alertCount = 0;
  int _lastSeenAlertCount = 0;
  bool get _hasUnreadAlerts => _alertCount > _lastSeenAlertCount;

  @override
  void initState() {
    super.initState();
    _loadAlertCount();
  }

  Future<void> _loadAlertCount() async {
    final alerts = await _appointmentService.getAppointmentAlerts();
    if (mounted) setState(() => _alertCount = alerts.length);
  }

  Future<void> _showDelayedAppointmentsDialog() async {
    final alerts = await _appointmentService.getAppointmentAlerts();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Delayed Appointments', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: alerts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 22),
                      SizedBox(width: 12),
                      Text('No delayed appointments'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: alerts.map<Widget>((a) {
                      final title = a['title'] as String? ?? 'Appointment update';
                      final message = a['message'] as String? ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFFF59E0B), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  if (message.isNotEmpty)
                                    Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF636388))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (mounted) {
      setState(() {
        _alertCount = alerts.length;
        _lastSeenAlertCount = alerts.length;
      });
    }
  }

  Future<void> _showLocationSheet() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111118),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._locations.map((loc) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.location_on, color: Color(0xFF1E88E5)),
                            title: Text(loc),
                            onTap: () => Navigator.pop(ctx, loc),
                          )),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.map_outlined, color: Color(0xFF1E88E5)),
                        title: const Text('Set on map', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Pick location on map'),
                        onTap: () async {
                          Navigator.pop(ctx);
                          final result = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapLocationScreen(),
                            ),
                          );
                          if (result != null && mounted) {
                            setState(() => _selectedLocation = result);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null && mounted) {
      setState(() => _selectedLocation = chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: textColor),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      GestureDetector(
                        onTap: _showLocationSheet,
                        child: Column(
                          children: [
                            const Text('LOCATION',
                                style: TextStyle(
                                    color: grayText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: primaryColor, size: 16),
                                const SizedBox(width: 4),
                                Text(_selectedLocation,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: primaryColor)),
                                const Icon(Icons.expand_more,
                                    color: primaryColor, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _showDelayedAppointmentsDialog,
                        icon: _hasUnreadAlerts
                            ? Badge(
                                smallSize: 8,
                                child: Icon(Icons.notifications_outlined,
                                    size: 28, color: textColor),
                              )
                            : Icon(Icons.notifications_none_outlined,
                                size: 28, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search specialty, doctor, or hospital...',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[400], size: 20),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const Icon(Icons.tune,
                              color: textColor, size: 18),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Specialties List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Most Popular',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllSpecialtiesScreen(),
                            ),
                          );
                        },
                        child: const Text('View All',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSpecialtySection([
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.face,
                      color: primaryColor,
                      bgColor: const Color(0xFFE3F2FD),
                      title: 'Dermatology',
                      subtitle: 'Skin, Hair & Nails',
                    ),
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.medical_services,
                      color: Colors.teal,
                      bgColor: const Color(0xFFE0F2F1),
                      title: 'Dentistry',
                      subtitle: 'Teeth & Oral Health',
                    ),
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.psychology,
                      color: Colors.indigo,
                      bgColor: const Color(0xFFEDE7F6),
                      title: 'Psychiatry',
                      subtitle: 'Mental Health',
                    ),
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.child_care,
                      color: Colors.orange,
                      bgColor: const Color(0xFFFFF3E0),
                      title: 'Pediatrics',
                      subtitle: 'Child & Infant Care',
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Other Specialties',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 16),
                  _buildSpecialtySection([
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.pregnant_woman,
                      color: Colors.pink,
                      bgColor: const Color(0xFFFCE4EC),
                      title: 'Gynaecology',
                      subtitle: "Women's Health",
                    ),
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.hearing,
                      color: Colors.lightBlue,
                      bgColor: const Color(0xFFE1F5FE),
                      title: 'Ear, Nose & Throat',
                      subtitle: 'ENT Specialist',
                    ),
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.favorite,
                      color: Colors.red,
                      bgColor: const Color(0xFFFFEBEE),
                      title: 'Cardiology',
                      subtitle: 'Heart & Vascular',
                    ),
                    _buildSpecialtyItem(
                      context,
                      icon: Icons.more_horiz,
                      color: Colors.grey,
                      bgColor: surfaceColor,
                      title: 'View All Specialties',
                      subtitle: '120+ categories',
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtySection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSpecialtyItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF111118)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF636388), fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: Color(0xFFD1D5DB), size: 14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectSpecialty3Screen(
            selectedSpecialty: title == 'View All Specialties' ? null : title,
          ),
        ),
      ),
    );
  }
}
