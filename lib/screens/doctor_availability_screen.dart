import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/mock_availability_service.dart';

/// Doctor weekly availability editor (local mock only; swap service for API later).
class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  static const _textColor = Color(0xFF111118);
  static const _surfaceColor = Color(0xFFF5F7FA);
  static const _primaryColor = Color(0xFF1E88E5);
  static const _mutedColor = Color(0xFF636388);

  final MockAvailabilityService _service = MockAvailabilityService.instance;
  late Map<String, DayAvailabilityModel> _draft;

  @override
  void initState() {
    super.initState();
    _draft = _service.copyState();
  }

  String _formatHhmm(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final dt = DateTime(2020, 1, 1, h, m);
    return DateFormat.jm().format(dt);
  }

  TimeOfDay _hhmmToTimeOfDay(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  /// Section-style title used in-list ("Available days", "Time slots"); matches picker help text.
  static const TextStyle _timePickerHeaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _textColor,
    height: 1.25,
  );

  /// Keeps [showTimePicker] within the viewport (web + mobile); avoids horizontal scroll.
  /// Styles [helpText] ("Start Time" / "End Time") like other screen section headers.
  Widget _buildTimePickerDialog(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    final screenW = MediaQuery.sizeOf(context).width;
    const margin = 24.0;
    // Never wider than 400 (Material guideline); never wider than screen minus margin.
    var maxW = screenW - margin;
    if (maxW > 400) maxW = 400;
    if (maxW < 1) maxW = screenW * 0.92;
    final themed = Theme(
      data: Theme.of(context).copyWith(
        timePickerTheme: TimePickerThemeData(
          helpTextStyle: _timePickerHeaderStyle,
        ),
      ),
      child: child,
    );
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: themed,
        ),
      ),
    );
  }

  String? _validateDraft() {
    for (final id in MockAvailabilityService.orderedDayIds) {
      final d = _draft[id]!;
      if (!d.enabled) continue;
      if (d.slots.isEmpty) {
        final label = MockAvailabilityService.dayLabels[id] ?? id;
        return 'Add at least one time slot for $label, or turn the day off.';
      }
      for (final s in d.slots) {
        if (!MockAvailabilityService.validateSlot(s.start, s.end)) {
          final label = MockAvailabilityService.dayLabels[id] ?? id;
          return 'End time must be after start time on $label.';
        }
      }
    }
    return null;
  }

  Future<void> _addSlot(String dayId) async {
    const initialStart = TimeOfDay(hour: 9, minute: 0);
    const initialEnd = TimeOfDay(hour: 11, minute: 0);

    if (!mounted) return;
    final pickedStart = await showTimePicker(
      context: context,
      initialTime: initialStart,
      helpText: 'Start Time',
      builder: _buildTimePickerDialog,
    );
    if (pickedStart == null || !mounted) return;

    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: initialEnd,
      helpText: 'End Time',
      builder: _buildTimePickerDialog,
    );
    if (pickedEnd == null || !mounted) return;

    final startStr = MockAvailabilityService.timeOfDayToHhmm(
      pickedStart.hour,
      pickedStart.minute,
    );
    final endStr = MockAvailabilityService.timeOfDayToHhmm(
      pickedEnd.hour,
      pickedEnd.minute,
    );

    if (!MockAvailabilityService.validateSlot(startStr, endStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _draft[dayId]!.slots.add(
            AvailabilitySlot(start: startStr, end: endStr),
          );
    });
  }

  Future<void> _editSlot(String dayId, int index) async {
    final slot = _draft[dayId]!.slots[index];
    if (!mounted) return;

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: _hhmmToTimeOfDay(slot.start),
      helpText: 'Start Time',
      builder: _buildTimePickerDialog,
    );
    if (pickedStart == null || !mounted) return;

    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: _hhmmToTimeOfDay(slot.end),
      helpText: 'End Time',
      builder: _buildTimePickerDialog,
    );
    if (pickedEnd == null || !mounted) return;

    final startStr = MockAvailabilityService.timeOfDayToHhmm(
      pickedStart.hour,
      pickedStart.minute,
    );
    final endStr = MockAvailabilityService.timeOfDayToHhmm(
      pickedEnd.hour,
      pickedEnd.minute,
    );

    if (!MockAvailabilityService.validateSlot(startStr, endStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _draft[dayId]!.slots[index] =
          AvailabilitySlot(start: startStr, end: endStr);
    });
  }

  void _removeSlot(String dayId, int index) {
    setState(() {
      _draft[dayId]!.slots.removeAt(index);
    });
  }

  void _onSave() {
    final err = _validateDraft();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    _service.applyState(_draft);
    _draft = _service.copyState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Availability updated successfully'),
        backgroundColor: Color(0xFF059669),
      ),
    );
    setState(() {});
  }

  void _toggleDay(String dayId, bool selected) {
    setState(() {
      _draft[dayId]!.enabled = selected;
      if (!selected) {
        _draft[dayId]!.slots.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabledDays = MockAvailabilityService.orderedDayIds
        .where((id) => _draft[id]!.enabled)
        .toList();

    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Availability',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _sectionTitle('Available days'),
                const SizedBox(height: 12),
                _daysCard(),
                const SizedBox(height: 28),
                _sectionTitle('Time slots'),
                const SizedBox(height: 8),
                Text(
                  'Set hours for each day you offer appointments.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _mutedColor.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                if (enabledDays.isEmpty)
                  _emptySlotsHint()
                else
                  ...enabledDays.map(_buildDaySection),
              ],
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _textColor,
      ),
    );
  }

  Widget _daysCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final id in MockAvailabilityService.orderedDayIds)
            FilterChip(
              label: Text(
                MockAvailabilityService.dayLabels[id] ?? id,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _draft[id]!.enabled ? _primaryColor : _mutedColor,
                ),
              ),
              selected: _draft[id]!.enabled,
              onSelected: (v) => _toggleDay(id, v),
              showCheckmark: true,
              checkmarkColor: _primaryColor,
              selectedColor: const Color(0xFFE3F2FD),
              backgroundColor: const Color(0xFFF5F7FA),
              side: BorderSide(
                color: _draft[id]!.enabled
                    ? _primaryColor.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptySlotsHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Turn on at least one day above, then add time slots.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: _mutedColor.withValues(alpha: 0.95),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildDaySection(String dayId) {
    final label = MockAvailabilityService.dayLabels[dayId] ?? dayId;
    final slots = _draft[dayId]!.slots;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (slots.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'No slots yet — tap Add slot.',
                  style: TextStyle(fontSize: 14, color: _mutedColor),
                ),
              )
            else
              ...List.generate(slots.length, (i) {
                final s = slots[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, i == slots.length - 1 ? 8 : 6),
                  child: Material(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _editSlot(dayId, i),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 22,
                              color: _primaryColor.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_formatHhmm(s.start)} – ${_formatHhmm(s.end)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove slot',
                              onPressed: () => _removeSlot(dayId, i),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: OutlinedButton.icon(
                onPressed: () => _addSlot(dayId),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text('Add slot'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor.withValues(alpha: 0.45)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
