import 'package:flutter/material.dart';
import 'doctor_bookings_screen.dart';
import 'home_screen_1.dart';

import 'doctor_dashboard_screen.dart';
import 'home_screen_3.dart';
import 'home_screen_4.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import '../services/messages_chat_store.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final bool isDoctor;
  const MainNavigationScreen({super.key, this.initialIndex = 0, this.isDoctor = false});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  // Keys for each tab's navigator
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    MessagesChatStore.ensureSeeded(widget.isDoctor);
    MessagesChatStore.version.addListener(_onMessagesStoreChanged);
  }

  @override
  void dispose() {
    MessagesChatStore.version.removeListener(_onMessagesStoreChanged);
    super.dispose();
  }

  void _onMessagesStoreChanged() {
    if (mounted) setState(() {});
  }

  bool _showMessagesTabBadge() {
    MessagesChatStore.ensureSeeded(widget.isDoctor);
    final n = MessagesChatStore.totalUnreadCount(widget.isDoctor);
    if (n <= 0) return false;
    if (_selectedIndex == 2) return false;
    if (MessagesChatStore.overlayMessagesScreenDepth > 0) return false;
    return true;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the current tab, pop to the root of that navigator
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final NavigatorState? currentNavigator =
            _navigatorKeys[_selectedIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else if (_selectedIndex != 0) {
          // If at the root of a secondary tab, go back to the home tab
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(
              0,
              widget.isDoctor
                  ? DoctorDashboardScreen(
                      doctorName: 'Doctor',
                      avatarImage: const NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAOHTWXNjI_gUoiqvZPVhKXRa8bU0__qYzHjrohW_qxz3OYC7XIJXuZMrukR-sZBnixaMvg9e6DbNlzOM7PC-TdFTmzzhd4HlsotiN2OQsK5PBM5DCkweI7jb94jr73C_z1_SdhKUIgwKRJ6ZrrDKxxTt3gwaCrA4pkkMtQWGsk-TyqcTWpcKM2vY1-iUMxgDD6-wpmUCPzqqX55fX2upRAgNTDErNF5YIKyOiVFeg88h5fD1r4b4_BKTsqdFOS2QIRNexJWuIfYAvK',
                      ),
                      onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      onAvatarTap: () => _onItemTapped(3),
                      onPatientBookingsTab: () => _onItemTapped(1),
                    )
                  : HomeScreen3(onProfilePressed: () => _onItemTapped(3)),
            ),
            _buildTabNavigator(
              1,
              widget.isDoctor
                  ? const DoctorBookingsScreen()
                  : const HomeScreen1(),
            ),
            _buildTabNavigator(
              2,
              MessagesScreen(isDoctor: widget.isDoctor),
            ),
            _buildTabNavigator(3, const HomeScreen4()),
          ],
        ),
        bottomNavigationBar: Container(
          height: 84,
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.calendar_month, 'Bookings', 1),
              _buildNavItem(
                Icons.chat_bubble,
                'Messages',
                2,
                showUnreadDot: _showMessagesTabBadge(),
              ),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => rootPage);
      },
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool showUnreadDot = false,
  }) {
    final bool isActive = _selectedIndex == index;
    const primaryColor = Color(0xFF1E88E5);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE3F2FD) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? primaryColor : Colors.grey[400],
                  size: 24,
                ),
                if (showUnreadDot)
                  Positioned(
                    right: -2,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isActive ? primaryColor : Colors.grey[400],
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
