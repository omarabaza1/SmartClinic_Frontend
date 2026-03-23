import 'package:flutter/foundation.dart';

/// In-app notifications for booking, cancellation, and doctor delay updates. No backend.
enum NotificationType { booking, cancellation, delay }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  /// Delay updates start unread; open notification list item to mark read.
  final bool read;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = true,
  });
}

class NotificationsStore {
  NotificationsStore._();

  static final List<NotificationItem> _list = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static void addBookingNotification({
    required String doctorName,
    required String dayLabel,
    required String timeSlot,
  }) {
    _list.insert(
      0,
      NotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.booking,
        title: 'Appointment booked',
        message:
            'Your appointment with $doctorName on $dayLabel at $timeSlot has been confirmed.',
        timestamp: DateTime.now(),
        read: true,
      ),
    );
    version.value++;
  }

  static void addCancellationNotification({
    required String doctorName,
    required String dayLabel,
    required String timeSlot,
  }) {
    _list.insert(
      0,
      NotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.cancellation,
        title: 'Appointment cancelled',
        message:
            'Your appointment with $doctorName on $dayLabel at $timeSlot was cancelled.',
        timestamp: DateTime.now(),
        read: true,
      ),
    );
    version.value++;
  }

  /// Patient-facing; starts **unread** until they open it in the notifications list.
  static void addDelayNotification({
    required String doctorName,
    required int minutesLate,
    String? note,
  }) {
    final extra = (note != null && note.trim().isNotEmpty)
        ? '\n${note.trim()}'
        : '';
    _list.insert(
      0,
      NotificationItem(
        id: 'delay-${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.delay,
        title: 'Update: $doctorName is delayed',
        message: 'Running approx. $minutesLate mins late.$extra',
        timestamp: DateTime.now(),
        read: false,
      ),
    );
    version.value++;
  }

  static void markAsRead(String id) {
    final idx = _list.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    final n = _list[idx];
    if (n.read) return;
    _list[idx] = NotificationItem(
      id: n.id,
      type: n.type,
      title: n.title,
      message: n.message,
      timestamp: n.timestamp,
      read: true,
    );
    version.value++;
  }

  static List<NotificationItem> get notifications =>
      List<NotificationItem>.from(_list);

  static int get unreadCount => _list.where((n) => !n.read).length;
}
