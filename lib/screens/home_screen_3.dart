import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../services/notifications_store.dart';
import 'ai_self_checkup_screen.dart';
import 'notifications_screen.dart';
import 'pharmacy_home_screen.dart';
import 'select_specialty_2.dart';
import 'select_specialty_3.dart';

class HomeScreen3 extends StatefulWidget {
  final VoidCallback? onProfilePressed;

  const HomeScreen3({super.key, this.onProfilePressed});

  @override
  State<HomeScreen3> createState() => _HomeScreen3State();
}

class _HomeScreen3State extends State<HomeScreen3> with WidgetsBindingObserver {
  final _authService = AuthService();
  final _appointmentService = AppointmentService();
  String _userName = 'Loading...';

  bool _hoverClinic = false;
  bool _hoverPharmacy = false;
  bool _hoverAi = false;
  int? _hoveredDoctorIndex;
  final TextEditingController _searchController = TextEditingController();

  int _alertCount = 0;
  int _lastSeenAlertCount = 0;
  bool get _hasUnreadAlerts => _alertCount > _lastSeenAlertCount;
  /// Unread items (e.g. doctor delay updates); booking/cancel start as read.
  int get _notificationCount => NotificationsStore.unreadCount;

  static const List<Map<String, dynamic>> _featuredDoctors = [
    {'name': 'Dr. James', 'specialty': 'Cardiologist', 'rating': 4.9, 'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBBQU7T6hKxC2hcykSq10KjcRPkZHwspJSoLU1W0v-UiCKVo_uYCmkeJRBdg1IS-01FhF2BdanbBDrhl-Wl2_FiU9KtlKvXjsmzmM8np5JD13uudoH4SGuJorJ7fezhWRRlYERJoyFxO06aO7puf3K3rM0eb7kfJMeV9x-oXY8xtdKE_btORHqI5ojtZxrC2DZg5iHWQdU7Eucf5FNIYpNs6aL2Yrme9ThW88DWVSO_024iokjewej7bSN4_aQPt43F4rt9-cvKw7lK', 'color': 0xFFC7B198},
    {'name': 'Dr. Sarah', 'specialty': 'Dentist', 'rating': 4.8, 'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDvSE2-2HXtPvhj_kcCwOoGKvA4edYnfpZsAVFUxF4-VWXLDAlOXlsm5M4jWV0AAYEYGMGGPVd9CtkDBiHymUZr8VgtXFA7i0Az-tSL4KzvSGhlTTgf9Q325YvWYk4MEihppMrhoRbJ8EvepiZYb5BfESimova5EW0L7QszR9RqO_HkoBvsWjOX8Df33ryt4_eARDfnZv0BRlphYOOudYND-H6KnRUKyTH1hfW1neEo73zfmBVpl2aaQFj4RB1jsYleP3GAfPLz91qi', 'color': 0xFF8DA494},
    {'name': 'Dr. Michael', 'specialty': 'Neurologist', 'rating': 4.7, 'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmUNXws7YrOlHnadPpwDkXMxH_Qttu9CLhaYoLg5uc0UPA_z7K0P8QISoqJl6R8z2hRz4bem-AI0wrlgPihXMmJQidrJwujCD6UOSjGGwjg4dzlB6IV4XpNIJCT5rf7i-XT_xyZyGGlVMgAKUD-djoHrSs2A554RD-A7TEO1ZVuHsIexJ9_66cYDXruDbjxlqpzElpwlony5fLRrN1m2lg3dyN4mCyB9A_ejbXDhsk8pyBxsbZAm8etfHIBBjNYOahJuUquWQRueGS', 'color': 0xFFD4C0A8},
    {'name': 'Dr. Emily', 'specialty': 'Dermatologist', 'rating': 4.9, 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'color': 0xFFE8B4B8},
    {'name': 'Dr. Ahmed', 'specialty': 'Pediatrician', 'rating': 4.6, 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'color': 0xFFB4D7E8},
    {'name': 'Dr. Lisa', 'specialty': 'Psychiatrist', 'rating': 4.8, 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'color': 0xFFD4B8E8},
    {'name': 'Dr. Omar', 'specialty': 'Orthopedist', 'rating': 4.7, 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'color': 0xFFC8E6C9},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationsStore.version.addListener(_onNotificationsChanged);
    _loadUserData();
    _loadAlertCount();
  }

  @override
  void dispose() {
    NotificationsStore.version.removeListener(_onNotificationsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadAlertCount();
  }

  Future<void> _loadAlertCount() async {
    final alerts = await _appointmentService.getAppointmentAlerts();
    if (mounted) setState(() => _alertCount = alerts.length);
  }


  Future<void> _loadUserData() async {
    final name = await _authService.getFullName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Guest User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: widget.onProfilePressed,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAOHTWXNjI_gUoiqvZPVhKXRa8bU0__qYzHjrohW_qxz3OYC7XIJXuZMrukR-sZBnixaMvg9e6DbNlzOM7PC-TdFTmzzhd4HlsotiN2OQsK5PBM5DCkweI7jb94jr73C_z1_SdhKUIgwKRJ6ZrrDKxxTt3gwaCrA4pkkMtQWGsk-TyqcTWpcKM2vY1-iUMxgDD6-wpmUCPzqqX55fX2upRAgNTDErNF5YIKyOiVFeg88h5fD1r4b4_BKTsqdFOS2QIRNexJWuIfYAvK'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Good evening,',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            Text(_userName,
                style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              icon: _notificationCount > 0
                  ? Badge(
                      label: Text('$_notificationCount'),
                      child: Icon(Icons.notifications_outlined, color: textColor, size: 26),
                    )
                  : Icon(Icons.notifications_none_outlined, color: textColor, size: 26),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Delay Alert Card
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                left: BorderSide(color: Color(0xFFF59E0B), width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.schedule,
                          color: Color(0xFFD97706), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Update: Dr. Sarah is delayed',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Running approx. 15 mins late',
                              style: TextStyle(
                                  color: grayText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showViewDetails(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFBEB),
                      foregroundColor: const Color(0xFFB45309),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View Details',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What would you like to do?',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          // Action Cards
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverClinic = true),
                  onExit: (_) => setState(() => _hoverClinic = false),
                  child: _buildActionCard(
                    context,
                    title: 'Clinic Visit',
                    subtitle: 'Book Doctors',
                    icon: Icons.apartment,
                    colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                    isHovered: _hoverClinic,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SelectSpecialty2Screen()),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverPharmacy = true),
                  onExit: (_) => setState(() => _hoverPharmacy = false),
                  child: _buildActionCard(
                    context,
                    title: 'Pharmacy',
                    subtitle: 'Medicines',
                    icon: Icons.medication,
                    colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                    isHovered: _hoverPharmacy,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PharmacyHomeScreen()),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // AI Health Assistant Card
          MouseRegion(
            onEnter: (_) => setState(() => _hoverAi = true),
            onExit: (_) => setState(() => _hoverAi = false),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AISelfCheckupScreen()),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 96,
                transform: Matrix4.identity()..scale(_hoverAi ? 1.02 : 1.0),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _hoverAi
                        ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                        : [const Color(0xFF2563EB), const Color(0xFF1E88E5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _hoverAi
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
              child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AI Health Assistant',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Run AI Checkup',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.smart_toy,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Book Appointment Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Book Clinic Appointment',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: textColor)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for specialty, doctor, or hospital',
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey[400], size: 22),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (value) {
                      final query = value.trim();
                      if (query.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectSpecialty3Screen(initialSearchQuery: query),
                          ),
                        ).then((_) {
                          if (mounted) _searchController.clear();
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectSpecialty2Screen(),
                          ),
                        ).then((_) {
                          if (mounted) _searchController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Featured Doctors Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured\nDoctors',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, height: 1.2)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectSpecialty3Screen(),
                  ),
                ),
                child: _buildFilterTab('All', true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Featured Doctors List
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: _featuredDoctors.length,
              itemBuilder: (context, index) {
                final d = _featuredDoctors[index];
                final isHovered = _hoveredDoctorIndex == index;
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredDoctorIndex = index),
                  onExit: (_) => setState(() => _hoveredDoctorIndex = null),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectSpecialty3Screen(),
                      ),
                    ),
                    child: _buildDoctorCard(
                      d['name'] as String,
                      d['specialty'] as String,
                      (d['rating'] as num).toDouble(),
                      d['imageUrl'] as String,
                      Color(d['color'] as int),
                      isHovered: isHovered,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isHovered = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 140,
        transform: Matrix4.identity()..scale(isHovered ? 1.03 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHovered
                ? [colors[0].withOpacity(0.95), colors[1]]
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(isHovered ? 0.45 : 0.3),
              blurRadius: isHovered ? 18 : 12,
              offset: Offset(0, isHovered ? 8 : 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.15),
                size: 80,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDelayedAppointmentsPopup(BuildContext context) async {
    final alerts = await _appointmentService.getAppointmentAlerts();
    if (!context.mounted) return;
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
                                  if (message.isNotEmpty) Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF636388))),
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

  void _showViewDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.schedule, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Update: Dr. Sarah is delayed',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text('Running approx. 15 mins late',
                          style: TextStyle(color: Color(0xFF636388), fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recommended arrival: 10:20 AM',
                style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF1E88E5) : const Color(0xFF636388),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
      String name, String specialty, double rating, String imageUrl, Color bg,
      {bool isHovered = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg.withOpacity(0.4),
                  image: DecorationImage(
                      image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 10),
                      const SizedBox(width: 2),
                      Text('$rating',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF111118))),
          Text(specialty,
              style: const TextStyle(color: Color(0xFF636388), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    if (isActive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF1E88E5), size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[400], size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
