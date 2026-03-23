import 'package:flutter/foundation.dart';

/// Frontend-only store of appointments the user has booked in the app.
/// Starts empty. Book → add with status BOOKED. Cancel → set CANCELLED.
/// Mark completed → set COMPLETED. Appointment History screen reads from here.
class AppointmentHistoryStore {
  AppointmentHistoryStore._();

  static final List<Map<String, dynamic>> _entries = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  /// Called when user confirms a booking. Adds entry with status 'booked'.
  static void addFromBooking({
    required String id,
    required String doctorId,
    required String dayLabel,
    required String doctorName,
    required String date,
    required String timeSlot,
    String? specialty,
  }) {
    _entries.insert(0, {
      'id': id,
      'doctor_id': doctorId,
      'day_label': dayLabel,
      'doctor_name': doctorName,
      'date': date,
      'time_slot': timeSlot,
      'specialty': specialty ?? 'Consultation',
      'status': 'booked',
    });
    version.value++;
  }

  /// Called when user cancels a booking. Keeps entry but sets status to 'cancelled'.
  static void markCancelled(String id) {
    final index = _entries.indexWhere((e) => e['id'] == id);
    if (index >= 0) {
      _entries[index]['status'] = 'cancelled';
      version.value++;
    }
  }

  /// Called when user marks an appointment as completed (e.g. from History screen).
  static void markCompleted(String id) {
    final index = _entries.indexWhere((e) => e['id'] == id);
    if (index >= 0) {
      _entries[index]['status'] = 'completed';
      version.value++;
    }
  }

  /// All history entries, newest first. Do not modify the returned list.
  static List<Map<String, dynamic>> getEntries() {
    return List<Map<String, dynamic>>.from(_entries);
  }
}
