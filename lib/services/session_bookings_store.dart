import 'package:flutter/foundation.dart';

import 'appointment_history_store.dart';
import 'booked_slots_store.dart';
import 'notifications_store.dart';

/// Holds appointments booked in the current session so they appear on the
/// Bookings screen. Listeners are notified when a new booking is added.
class SessionBookingsStore {
  SessionBookingsStore._();

  static final List<Map<String, dynamic>> _bookings = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static final Set<String> _cancelledMockIds = {};

  static void addBooking({
    required String doctorId,
    required String dayLabel,
    required String doctorName,
    required String date,
    required String timeSlot,
    String? specialty,
    String? patientName,
  }) {
    final id = 'session-${DateTime.now().millisecondsSinceEpoch}';
    _bookings.add({
      'id': id,
      'doctor_id': doctorId,
      'day_label': dayLabel,
      'date': date,
      'time_slot': timeSlot,
      'doctor_name': doctorName,
      'specialty': specialty ?? 'Consultation',
      'patient_name': patientName ?? 'Patient',
    });
    AppointmentHistoryStore.addFromBooking(
      id: id,
      doctorId: doctorId,
      dayLabel: dayLabel,
      doctorName: doctorName,
      date: date,
      timeSlot: timeSlot,
      specialty: specialty,
    );
    version.value++;
  }

  /// Remove a session booking by id. Frees the slot, marks as cancelled in history, adds notification.
  static void removeBooking(String id) {
    final index = _bookings.indexWhere((b) => b['id'] == id);
    if (index >= 0) {
      final b = _bookings[index];
      final doctorId = b['doctor_id'] as String?;
      final dayLabel = b['day_label'] as String?;
      final timeSlot = b['time_slot'] as String?;
      final doctorName = b['doctor_name'] as String? ?? 'Doctor';
      if (doctorId != null && dayLabel != null && timeSlot != null) {
        BookedSlotsStore.removeBookedSlot(doctorId, dayLabel, timeSlot);
      }
      NotificationsStore.addCancellationNotification(
        doctorName: doctorName,
        dayLabel: dayLabel ?? '',
        timeSlot: timeSlot ?? '',
      );
      AppointmentHistoryStore.markCancelled(id);
      _bookings.removeAt(index);
    }
    version.value++;
  }

  /// Mark a mock appointment (e.g. 'apt-1', 'up-1') as cancelled. Notifies listeners.
  static void cancelMockAppointment(String id) {
    _cancelledMockIds.add(id);
    version.value++;
  }

  static bool isMockCancelled(String id) => _cancelledMockIds.contains(id);

  static bool _isToday(String dateStr) {
    final now = DateTime.now();
    final parts = dateStr.split('-');
    if (parts.length != 3) return false;
    final y = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    return y == now.year && m == now.month && d == now.day;
  }

  static bool _isFuture(String dateStr) {
    final now = DateTime.now();
    final parts = dateStr.split('-');
    if (parts.length != 3) return false;
    final y = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    final dt = DateTime(y, m, d);
    return dt.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Parses "2:00 PM" into time "02:00" and period "PM".
  static (String time, String period) parseTimeSlot(String timeSlot) {
    final parts = timeSlot.trim().split(RegExp(r'\s+'));
    final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
    final t = parts[0].split(':');
    final h = int.tryParse(t[0]) ?? 0;
    final m = int.tryParse(t.length > 1 ? t[1] : '0') ?? 0;
    return ('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}', amPm);
  }

  /// Bookings for today (date equals today). Shape for today's appointment card.
  static List<Map<String, dynamic>> getTodayBookings() {
    return _bookings.where((b) => _isToday(b['date'] as String? ?? '')).toList();
  }

  /// Bookings for future dates. Shape for upcoming card (month, day, etc.).
  static List<Map<String, dynamic>> getUpcomingBookings() {
    return _bookings.where((b) => _isFuture(b['date'] as String? ?? '')).toList();
  }

  /// Incoming bookings for a doctor inbox (same date rules as today/upcoming).
  static List<Map<String, dynamic>> getTodayBookingsForDoctor(String doctorId) {
    return getTodayBookings()
        .where((b) => (b['doctor_id'] as String?) == doctorId)
        .toList();
  }

  static List<Map<String, dynamic>> getUpcomingBookingsForDoctor(
      String doctorId) {
    return getUpcomingBookings()
        .where((b) => (b['doctor_id'] as String?) == doctorId)
        .toList();
  }
}
