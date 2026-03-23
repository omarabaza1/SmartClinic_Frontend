import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import '../services/booked_slots_store.dart';
import '../services/notifications_store.dart';
import '../services/profile_session_store.dart';
import '../services/session_bookings_store.dart';

class SelectSpecialty1Screen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;

  const SelectSpecialty1Screen({super.key, this.doctorId, this.doctorName});

  @override
  State<SelectSpecialty1Screen> createState() => _SelectSpecialty1ScreenState();
}

class _SelectSpecialty1ScreenState extends State<SelectSpecialty1Screen> {
  final AppointmentService _appointmentService = AppointmentService();
  int _selectedDayIndex = 0;

  static const List<Map<String, String>> _daysConfig = [
    {'label': 'Today', 'start': '12:30 PM', 'end': '9:30 PM'},
    {'label': 'Tomorrow', 'start': '1:00 PM', 'end': '9:30 PM'},
    {'label': 'Monday 5/1', 'start': '12:30 PM', 'end': '9:30 PM'},
  ];

  List<String> _timeSlotsForRange(String start, String end) {
    const intervalMinutes = 30;
    final startM = _timeToMinutes(start);
    final endM = _timeToMinutes(end);
    final slots = <String>[];
    for (int m = startM; m <= endM; m += intervalMinutes) {
      slots.add(_minutesToTime(m));
    }
    return slots;
  }

  int _timeToMinutes(String time) {
    final parts = time.trim().split(RegExp(r'\s+'));
    final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
    final t = parts[0].split(':');
    int h = int.tryParse(t[0]) ?? 0;
    int min = int.tryParse(t.length > 1 ? t[1] : '0') ?? 0;
    if (amPm == 'PM' && h != 12) h += 12;
    if (amPm == 'AM' && h == 12) h = 0;
    return h * 60 + min;
  }

  String _minutesToTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final isPm = h >= 12;
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final amPm = isPm ? 'PM' : 'AM';
    return '$hour:${m.toString().padLeft(2, '0')} $amPm';
  }

  String _dateForApi(String dayLabel) {
    final now = DateTime.now();
    switch (dayLabel) {
      case 'Today':
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      case 'Tomorrow':
        final t = now.add(const Duration(days: 1));
        return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
      default:
        final t = now.add(const Duration(days: 2));
        return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _onSlotTap(String dayLabel, String timeSlot) async {
    final doctorId = widget.doctorId ?? 'default';
    if (BookedSlotsStore.isBooked(doctorId, dayLabel, timeSlot)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm appointment'),
        content: Text(
          'Book with ${widget.doctorName ?? 'Dr. Sarah Johnson'} on $dayLabel at $timeSlot?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final date = _dateForApi(dayLabel);
    await _appointmentService.bookAppointment(
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
    );
    BookedSlotsStore.addBookedSlot(doctorId, dayLabel, timeSlot);
    final doctorName = widget.doctorName ?? 'Dr. Sarah Johnson';
    SessionBookingsStore.addBooking(
      doctorId: doctorId,
      dayLabel: dayLabel,
      doctorName: doctorName,
      date: date,
      timeSlot: timeSlot,
      specialty: null,
      patientName: ProfileSessionStore.fullName ?? 'Guest patient',
    );
    NotificationsStore.addBookingNotification(
      doctorName: doctorName,
      dayLabel: dayLabel,
      timeSlot: timeSlot,
    );
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment confirmed for $dayLabel at $timeSlot'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    final doctorId = widget.doctorId ?? 'default';
    final doctorName = widget.doctorName ?? 'Dr. Sarah Johnson';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Doctor Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://cdn-icons-png.flaticon.com/512/3774/3774299.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(
                                    4,
                                    (index) => const Icon(Icons.star,
                                        color: Colors.amber, size: 18)),
                                const Icon(Icons.star_border,
                                    color: Colors.amber, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Overall Rating From 158 Visitors',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Consultant Dermatologist,\nCosmetologist and Laser',
                              style: TextStyle(
                                  color: grayText, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Online',
                                    style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildTag(Icons.hearing, 'Good Listener'),
                      const SizedBox(width: 12),
                      _buildTag(Icons.sentiment_satisfied_alt, 'Friendly'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.payments_outlined, 'Fees: 600 EGP'),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFF1F5F9), indent: 52),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      SizedBox(width: 52),
                      Text('Waiting Time 8 min',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFF1F5F9), indent: 52),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'El-Rehab: AlRehab gate 5',
                    subtitle: 'Book and you will receive the address details',
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'Choose your appointment',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _daysConfig.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final label = _daysConfig[index]['label']!;
                        final isSelected = index == _selectedDayIndex;
                        return Material(
                          color: isSelected
                              ? primaryColor
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedDayIndex = index),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : grayText,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (context) {
                      final day = _daysConfig[_selectedDayIndex];
                      final label = day['label']!;
                      final start = day['start']!;
                      final end = day['end']!;
                      final slots = _timeSlotsForRange(start, end);
                      return _buildDaySection(
                        context,
                        doctorId: doctorId,
                        dayLabel: label,
                        slots: slots,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Time slot reservation',
                      style: TextStyle(color: grayText, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context, {
    required String doctorId,
    required String dayLabel,
    required List<String> slots,
  }) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              dayLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((timeSlot) {
                final isBooked =
                    BookedSlotsStore.isBooked(doctorId, dayLabel, timeSlot);
                return _buildSlotChip(
                  timeSlot: timeSlot,
                  isBooked: isBooked,
                  onTap: () => _onSlotTap(dayLabel, timeSlot),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotChip({
    required String timeSlot,
    required bool isBooked,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF1E88E5);
    const grayText = Color(0xFF636388);

    return Material(
      color: isBooked
          ? const Color(0xFFF1F5F9)
          : const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isBooked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBooked ? const Color(0xFFE2E8F0) : primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBooked ? Icons.block : Icons.schedule,
                size: 18,
                color: isBooked ? grayText : primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                timeSlot,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isBooked ? grayText : const Color(0xFF111118),
                  decoration: isBooked ? TextDecoration.lineThrough : null,
                ),
              ),
              if (isBooked) ...[
                const SizedBox(width: 6),
                const Text(
                  'Booked',
                  style: TextStyle(
                    fontSize: 11,
                    color: grayText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E88E5), size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF636388),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1E88E5), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111118))),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF636388))),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
