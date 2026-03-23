import 'package:flutter/material.dart';
import '../services/notifications_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _primaryColor = Color(0xFF1E88E5);
  static const _textColor = Color(0xFF111118);
  static const _grayText = Color(0xFF636388);
  static const _surfaceColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    NotificationsStore.version.addListener(_onChanged);
  }

  @override
  void dispose() {
    NotificationsStore.version.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String _formatTimestamp(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final list = NotificationsStore.notifications;

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
          'Notifications',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: _grayText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final n = list[index];
                return _buildCard(n);
              },
            ),
    );
  }

  Widget _buildCard(NotificationItem n) {
    final isBooking = n.type == NotificationType.booking;
    final isDelay = n.type == NotificationType.delay;
    final isCancellation = n.type == NotificationType.cancellation;

    final IconData icon;
    final Color iconColor;
    final Color iconBg;
    if (isDelay) {
      icon = Icons.schedule_send_rounded;
      iconColor = const Color(0xFFEA580C);
      iconBg = const Color(0xFFFFF7ED);
    } else if (isBooking) {
      icon = Icons.event_available_rounded;
      iconColor = const Color(0xFF059669);
      iconBg = const Color(0xFFF0FDF4);
    } else {
      icon = Icons.event_busy_rounded;
      iconColor = const Color(0xFFDC2626);
      iconBg = const Color(0xFFFEF2F2);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (!n.read) {
            NotificationsStore.markAsRead(n.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: !n.read && isDelay
                ? Border.all(color: const Color(0xFFFDBA74), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  if (!n.read)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            !n.read ? FontWeight.w800 : FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: _grayText,
                        height: 1.35,
                        fontWeight: !n.read && isDelay
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(n.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: _grayText.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
