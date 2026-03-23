import 'package:flutter/material.dart';

import '../constants/doctor_session.dart';
import '../services/appointment_delay_store.dart';
import '../services/session_bookings_store.dart';
import '../widgets/notify_patient_delay_sheet.dart';

/// Doctor-facing inbox: patient bookings for this doctor only.
/// Patients keep using [HomeScreen1] on the Bookings tab.
///
/// [_doctorPatientBookingsPreview] is **doctor-only** mock data (not shared with patient UI).
class DoctorBookingsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorBookingsScreen({
    super.key,
    this.doctorId = DoctorSession.currentDoctorId,
  });

  @override
  State<DoctorBookingsScreen> createState() => _DoctorBookingsScreenState();
}

class _DoctorBookingsScreenState extends State<DoctorBookingsScreen> {
  static const _surface = Color(0xFFF5F7FA);
  static const _text = Color(0xFF111118);
  static const _muted = Color(0xFF636388);
  static const _primaryColor = Color(0xFF1E88E5);

  /// Local-only preview rows for the doctor Bookings tab (separate from patient stores).
  static final List<Map<String, dynamic>> _doctorPatientBookingsPreview = [
    {
      'id': 'doc-pb-mock-1',
      'isDoctorPreviewMock': true,
      'patient_name': 'Sarah Ahmed',
      'imageUrl': 'https://i.pravatar.cc/150?img=16',
      'specialty': 'Dental checkup',
      'day_label': 'Today',
      'time_slot': '10:00 AM',
      'date': '',
      'booking_status': 'confirmed',
      'doctor_name': 'Dr. Sarah Johnson',
    },
    {
      'id': 'doc-pb-mock-2',
      'isDoctorPreviewMock': true,
      'patient_name': 'Omar Khaled',
      'imageUrl': 'https://i.pravatar.cc/150?img=33',
      'specialty': 'Follow-up visit',
      'day_label': 'Today',
      'time_slot': '11:30 AM',
      'date': '',
      'booking_status': 'pending',
      'doctor_name': 'Dr. Sarah Johnson',
    },
    {
      'id': 'doc-pb-mock-3',
      'isDoctorPreviewMock': true,
      'patient_name': 'Mariam Adel',
      'imageUrl': 'https://i.pravatar.cc/150?img=45',
      'specialty': 'Skin consultation',
      'day_label': 'Today',
      'time_slot': '02:00 PM',
      'date': '',
      'booking_status': 'confirmed',
      'doctor_name': 'Dr. Alyson Reed',
    },
    {
      'id': 'doc-pb-mock-4',
      'isDoctorPreviewMock': true,
      'patient_name': 'Youssef Tarek',
      'imageUrl': 'https://i.pravatar.cc/150?img=52',
      'specialty': 'General checkup',
      'day_label': 'Today',
      'time_slot': '04:15 PM',
      'date': '',
      'booking_status': 'confirmed',
      'doctor_name': 'Dr. Sarah Johnson',
    },
  ];

  /// Preview mocks dismissed in-session (no backend).
  final Set<String> _removedPreviewMockIds = {};

  @override
  void initState() {
    super.initState();
    SessionBookingsStore.version.addListener(_onChanged);
    AppointmentDelayStore.version.addListener(_onChanged);
  }

  @override
  void dispose() {
    SessionBookingsStore.version.removeListener(_onChanged);
    AppointmentDelayStore.version.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> _visiblePreviewMocks() {
    return _doctorPatientBookingsPreview
        .where((m) => !_removedPreviewMockIds.contains(m['id'] as String))
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  Future<void> _confirmRemove(Map<String, dynamic> b) async {
    final patient = b['patient_name'] as String? ?? 'Patient';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove booking'),
        content: Text(
          'Remove $patient from your schedule for this slot? The patient will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final id = b['id'] as String? ?? '';
    AppointmentDelayStore.clearDelay(id);

    if (b['isDoctorPreviewMock'] == true) {
      setState(() => _removedPreviewMockIds.add(id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preview booking removed'),
            backgroundColor: Color(0xFFEA580C),
          ),
        );
      }
      return;
    }

    SessionBookingsStore.removeBooking(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking removed'),
          backgroundColor: Color(0xFFEA580C),
        ),
      );
    }
  }

  void _openDelay(Map<String, dynamic> b) {
    final id = b['id'] as String? ?? '';
    final doctorNameForNotif =
        b['doctor_name'] as String? ?? DoctorSession.displayName;
    final slot = b['time_slot'] as String? ?? '';
    final (time, period) = SessionBookingsStore.parseTimeSlot(slot);
    showNotifyPatientDelaySheet(
      context,
      appointmentId: id,
      doctorName: doctorNameForNotif,
      time: time,
      period: period,
      onSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patients have been notified of the delay'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      },
    );
  }

  String _formatUpcomingDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final m = int.tryParse(parts[1]) ?? 1;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final mo = months[m.clamp(1, 12) - 1];
    return '$mo ${parts[2]}, ${parts[0]}';
  }

  /// Maps [booking_status] + delay to colors/labels matching [HomeScreen1] appointment cards.
  ({
    Color statusColor,
    String chipLabel,
    String statusLine,
    IconData statusIcon,
  }) _resolveStatus(Map<String, dynamic> b, AppointmentDelayEntry? delay) {
    if (delay != null) {
      return (
        statusColor: const Color(0xFFEA580C),
        chipLabel: 'DELAYED',
        statusLine: delay.statusLine,
        statusIcon: Icons.error_outline_rounded,
      );
    }
    final raw = (b['booking_status'] as String? ?? 'confirmed').toLowerCase();
    if (raw == 'pending') {
      return (
        statusColor: const Color(0xFFD97706),
        chipLabel: 'PENDING',
        statusLine: 'Awaiting confirmation',
        statusIcon: Icons.schedule_rounded,
      );
    }
    if (raw == 'cancelled') {
      return (
        statusColor: const Color(0xFF64748B),
        chipLabel: 'CANCELLED',
        statusLine: 'Cancelled',
        statusIcon: Icons.cancel_outlined,
      );
    }
    return (
      statusColor: _primaryColor,
      chipLabel: 'CONFIRMED',
      statusLine: 'Confirmed',
      statusIcon: Icons.check_circle_outline_rounded,
    );
  }

  /// Same header layout as [HomeScreen1] `_buildAppointmentCard`: avatar + chip, name, subtitle, status row, time box.
  Widget _appointmentStyleCard(Map<String, dynamic> b, {required bool isToday}) {
    final id = b['id'] as String? ?? '';
    final patient = b['patient_name'] as String? ?? 'Patient';
    final specialty = b['specialty'] as String? ?? 'Consultation';
    final dayLabel = b['day_label'] as String? ?? '';
    final timeSlot = b['time_slot'] as String? ?? '';
    final dateStr = b['date'] as String? ?? '';
    final imageUrl = b['imageUrl'] as String?;
    final delay = AppointmentDelayStore.entryFor(id);
    final resolved = _resolveStatus(b, delay);
    final statusColor = resolved.statusColor;
    final chipLabel = resolved.chipLabel;
    final statusLine = resolved.statusLine;
    final statusIcon = resolved.statusIcon;

    final (timeStr, periodStr) = SessionBookingsStore.parseTimeSlot(timeSlot);

    final scheduleSubtitle =
        isToday ? '$dayLabel · $timeSlot' : '${_formatUpcomingDate(dateStr)} · $timeSlot';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: statusColor, width: 8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        image: imageUrl != null && imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl == null || imageUrl.isEmpty
                          ? Center(
                              child: Text(
                                patient.isNotEmpty
                                    ? patient
                                        .trim()
                                        .split(RegExp(r'\s+'))
                                        .map((e) => e[0])
                                        .take(2)
                                        .join()
                                        .toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          chipLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: _text,
                        ),
                      ),
                      Text(
                        specialty,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              statusLine,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        periodStr,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_note_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scheduleSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _text,
                        ),
                      ),
                    ),
                  ],
                ),
                if (delay != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delay.statusLine,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF431407),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Suggested patient arrival: ${delay.recommendedArrivalDisplay}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openDelay(b),
                        icon: const Icon(Icons.schedule_send_rounded, size: 20),
                        label: const Text('Notify delay'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEA580C),
                          side: const BorderSide(color: Color(0xFFFDBA74)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _confirmRemove(b),
                        icon: const Icon(Icons.person_off_outlined, size: 20),
                        label: const Text('Remove'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewToday = _visiblePreviewMocks();
    final todaySession =
        SessionBookingsStore.getTodayBookingsForDoctor(widget.doctorId);
    final upcoming =
        SessionBookingsStore.getUpcomingBookingsForDoctor(widget.doctorId);

    final today = <Map<String, dynamic>>[
      ...previewToday,
      ...todaySession.map((e) => Map<String, dynamic>.from(e)),
    ];

    final total = today.length + upcoming.length;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text(
              'Patient bookings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _text,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Appointments patients booked with you.',
              style: TextStyle(fontSize: 14, color: _muted.withOpacity(0.95)),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total active',
                  style: const TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (total == 0)
              _emptyState()
            else ...[
              if (today.isNotEmpty) ...[
                _sectionTitle('Today'),
                const SizedBox(height: 12),
                ...today.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _appointmentStyleCard(b, isToday: true),
                    )),
                const SizedBox(height: 8),
              ],
              if (upcoming.isNotEmpty) ...[
                _sectionTitle('Upcoming'),
                const SizedBox(height: 12),
                ...upcoming.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _appointmentStyleCard(b, isToday: false),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _text,
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_outlined,
              size: 56, color: _muted.withOpacity(0.45)),
          const SizedBox(height: 16),
          const Text(
            'No patient bookings yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When patients book an appointment with you, it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _muted.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
