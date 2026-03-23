import 'package:flutter/foundation.dart';

/// One bookable time range per day (24h strings "HH:mm" for easy compare / future API).
@immutable
class AvailabilitySlot {
  const AvailabilitySlot({required this.start, required this.end});

  final String start;
  final String end;

  Map<String, String> toJson() => {'start': start, 'end': end};

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }

  AvailabilitySlot copy() =>
      AvailabilitySlot(start: start, end: end);
}

/// Local model for a weekday: on/off + ranges (in-memory only).
class DayAvailabilityModel {
  DayAvailabilityModel({
    this.enabled = false,
    List<AvailabilitySlot>? slots,
  }) : slots = slots ?? [];

  bool enabled;
  List<AvailabilitySlot> slots;

  DayAvailabilityModel copy() => DayAvailabilityModel(
        enabled: enabled,
        slots: slots.map((s) => s.copy()).toList(),
      );
}

/// Singleton mock store for doctor weekly availability.
/// Replace persistence calls later with API / repository.
class MockAvailabilityService {
  MockAvailabilityService._();

  static final MockAvailabilityService instance = MockAvailabilityService._();

  static const List<String> orderedDayIds = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const Map<String, String> dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  final Map<String, DayAvailabilityModel> _days = {
    for (final id in orderedDayIds) id: DayAvailabilityModel(),
  };

  /// Shape matches future REST body, e.g. `{ "monday": [ {"start":"09:00","end":"11:00"} ] }`.
  /// Disabled days export as empty lists.
  Map<String, dynamic> getAvailability() {
    final out = <String, dynamic>{};
    for (final id in orderedDayIds) {
      final d = _days[id]!;
      if (!d.enabled || d.slots.isEmpty) {
        out[id] = <Map<String, String>>[];
      } else {
        out[id] = d.slots.map((s) => s.toJson()).toList();
      }
    }
    return out;
  }

  /// Load from API-shaped map (empty list = day off).
  void saveAvailability(Map<String, dynamic> data) {
    for (final id in orderedDayIds) {
      final raw = data[id];
      final model = _days[id]!;
      model.slots.clear();
      if (raw is! List || raw.isEmpty) {
        model.enabled = false;
        continue;
      }
      model.enabled = true;
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          model.slots.add(AvailabilitySlot.fromJson(item));
        }
      }
    }
  }

  /// Deep copy for UI draft.
  Map<String, DayAvailabilityModel> copyState() {
    return {
      for (final id in orderedDayIds) id: _days[id]!.copy(),
    };
  }

  /// Persist edited draft from the screen (after validation).
  void applyState(Map<String, DayAvailabilityModel> draft) {
    for (final id in orderedDayIds) {
      final src = draft[id]!;
      final dst = _days[id]!;
      dst.enabled = src.enabled;
      dst.slots
        ..clear()
        ..addAll(src.slots.map((s) => s.copy()));
    }
  }

  void updateDay(String dayKey, bool enabled) {
    final d = _days[dayKey];
    if (d == null) return;
    d.enabled = enabled;
    if (!enabled) d.slots.clear();
  }

  /// Returns false if invalid (end <= start).
  bool addSlot(String dayKey, String start, String end) {
    if (!validateSlot(start, end)) return false;
    _days[dayKey]?.slots.add(AvailabilitySlot(start: start, end: end));
    return true;
  }

  void removeSlot(String dayKey, int index) {
    final list = _days[dayKey]?.slots;
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
  }

  static int? _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return h * 60 + m;
  }

  static bool validateSlot(String start, String end) {
    final a = _toMinutes(start);
    final b = _toMinutes(end);
    if (a == null || b == null) return false;
    return b > a;
  }

  static String timeOfDayToHhmm(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
