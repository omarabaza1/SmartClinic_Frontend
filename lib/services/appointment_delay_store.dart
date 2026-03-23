import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Single delay update for one appointment (in-memory; replace with API later).
@immutable
class AppointmentDelayEntry {
  const AppointmentDelayEntry({
    required this.appointmentId,
    required this.minutesLate,
    required this.doctorName,
    required this.recommendedArrivalDisplay,
    this.note,
    required this.updatedAt,
  });

  final String appointmentId;
  final int minutesLate;
  final String doctorName;
  /// Shown on the patient card, e.g. "10:15 AM"
  final String recommendedArrivalDisplay;
  final String? note;
  final DateTime updatedAt;

  /// Line under the doctor name on the booking card.
  String get statusLine {
    final base = 'Running approx. $minutesLate mins late';
    if (note != null && note!.trim().isNotEmpty) {
      return '$base • ${note!.trim()}';
    }
    return '$base.';
  }
}

/// Singleton: doctor-set delays visible to patient booking UI + notifications.
/// Later: sync from repository / WebSocket.
class AppointmentDelayStore {
  AppointmentDelayStore._();

  static final Map<String, AppointmentDelayEntry> _byId = {};
  static final ValueNotifier<int> version = ValueNotifier(0);

  static AppointmentDelayEntry? entryFor(String appointmentId) =>
      _byId[appointmentId];

  static bool hasEntry(String appointmentId) => _byId.containsKey(appointmentId);

  /// [time] = "10:00", [period] = "AM" | "PM" (as on HomeScreen1 cards).
  static void setDelay({
    required String appointmentId,
    required int minutesLate,
    required String doctorName,
    required String time,
    required String period,
    String? note,
  }) {
    final recommend =
        _recommendedArrival(time: time, period: period, addMinutes: minutesLate);
    _byId[appointmentId] = AppointmentDelayEntry(
      appointmentId: appointmentId,
      minutesLate: minutesLate,
      doctorName: doctorName,
      recommendedArrivalDisplay: recommend,
      note: note,
      updatedAt: DateTime.now(),
    );
    version.value++;
  }

  static void clearDelay(String appointmentId) {
    _byId.remove(appointmentId);
    version.value++;
  }

  static String _recommendedArrival({
    required String time,
    required String period,
    required int addMinutes,
  }) {
    final parts = time.split(':');
    var h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final p = period.toUpperCase();
    if (p == 'PM' && h != 12) h += 12;
    if (p == 'AM' && h == 12) h = 0;
    var dt = DateTime(2000, 1, 1, h, m);
    dt = dt.add(Duration(minutes: addMinutes));
    return DateFormat.jm().format(dt);
  }

  /// For upcoming cards that only have a single label like "09:00 AM".
  static void setDelayFromTimeLabel({
    required String appointmentId,
    required int minutesLate,
    required String doctorName,
    required String time12hLabel,
    String? note,
  }) {
    final recommend =
        _recommendedArrivalFromLabel(time12hLabel, minutesLate);
    _byId[appointmentId] = AppointmentDelayEntry(
      appointmentId: appointmentId,
      minutesLate: minutesLate,
      doctorName: doctorName,
      recommendedArrivalDisplay: recommend,
      note: note,
      updatedAt: DateTime.now(),
    );
    version.value++;
  }

  static String _recommendedArrivalFromLabel(String label, int addMinutes) {
    try {
      final dt = DateFormat.jm().parse(label.trim());
      return DateFormat.jm()
          .format(dt.add(Duration(minutes: addMinutes)));
    } catch (_) {
      return label;
    }
  }

  /// Debug / future API export.
  static Map<String, dynamic> exportJson() {
    return {
      for (final e in _byId.entries)
        e.key: {
          'minutesLate': e.value.minutesLate,
          'note': e.value.note,
          'doctorName': e.value.doctorName,
          'recommendedArrival': e.value.recommendedArrivalDisplay,
          'updatedAt': e.value.updatedAt.toIso8601String(),
        },
    };
  }
}
