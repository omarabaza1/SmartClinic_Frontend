import 'package:flutter/material.dart';
import 'all_specialties_screen.dart';
import '../constants/doctor_session.dart';
import '../services/appointment_delay_store.dart';
import '../services/notifications_store.dart';
import '../services/session_bookings_store.dart';
import '../widgets/notify_patient_delay_sheet.dart';

class HomeScreen1 extends StatefulWidget {
  /// When true (e.g. doctor "View today's appointments"), only today's
  /// appointments are shown; upcoming section and "Book a New Appointment" are hidden.
  final bool todayOnlyView;

  /// When true (pushed from doctor dashboard), shows an AppBar with back to dashboard.
  /// Patient tab uses default false so layout is unchanged.
  final bool showDoctorAppBar;

  /// Patients see the floating "Book a New Appointment" CTA; doctors do not.
  final bool showBookAppointmentButton;

  const HomeScreen1({
    super.key,
    this.todayOnlyView = false,
    this.showDoctorAppBar = false,
    this.showBookAppointmentButton = true,
  });

  @override
  State<HomeScreen1> createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  static const String _defaultImage =
      'https://cdn-icons-png.flaticon.com/512/3774/3774299.png';

  /// Shown only on doctor "Today's Appointments" (patient-centric preview rows).
  static const List<Map<String, String>> _doctorTodayPreviewMocks = [
    {
      'id': 'doc-today-1',
      'patientName': 'Jordan Lee',
      'imageUrl': 'https://i.pravatar.cc/150?img=12',
      'visitType': 'Dental checkup · Follow-up',
      'time': '10:00',
      'period': 'AM',
      'notifyAsDoctor': 'Dr. Sarah Johnson',
    },
    {
      'id': 'doc-today-2',
      'patientName': 'Priya Sharma',
      'imageUrl': 'https://i.pravatar.cc/150?img=47',
      'visitType': 'Dermatology consult · New patient',
      'time': '02:30',
      'period': 'PM',
      'notifyAsDoctor': 'Dr. Alyson Reed',
    },
    {
      'id': 'doc-today-3',
      'patientName': 'Marcus Cole',
      'imageUrl': 'https://i.pravatar.cc/150?img=33',
      'visitType': 'Hypertension follow-up',
      'time': '04:15',
      'period': 'PM',
      'notifyAsDoctor': 'Dr. Sarah Johnson',
    },
  ];

  @override
  void initState() {
    super.initState();
    SessionBookingsStore.version.addListener(_onBookingsChanged);
    AppointmentDelayStore.version.addListener(_onBookingsChanged);
  }

  @override
  void dispose() {
    SessionBookingsStore.version.removeListener(_onBookingsChanged);
    AppointmentDelayStore.version.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openNotifyDelaySheet({
    required String appointmentId,
    required String doctorName,
    String? time,
    String? period,
    String? time12hLabel,
  }) async {
    await showNotifyPatientDelaySheet(
      context,
      appointmentId: appointmentId,
      doctorName: doctorName,
      time: time,
      period: period,
      time12hLabel: time12hLabel,
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

  Future<void> _showCancelConfirm(
    BuildContext context,
    String id,
    bool isMock, {
    String? doctorName,
    String? dayLabel,
    String? timeSlot,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    AppointmentDelayStore.clearDelay(id);
    if (isMock) {
      SessionBookingsStore.cancelMockAppointment(id);
      NotificationsStore.addCancellationNotification(
        doctorName: doctorName ?? 'Doctor',
        dayLabel: dayLabel ?? '',
        timeSlot: timeSlot ?? '',
      );
    } else {
      SessionBookingsStore.removeBooking(id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  List<Widget> _buildTodayCards() {
    if (widget.todayOnlyView && widget.showDoctorAppBar) {
      return _buildDoctorTodayPatientCards();
    }

    final cards = <Widget>[];
    final doctorMode = widget.showDoctorAppBar;

    if (!SessionBookingsStore.isMockCancelled('apt-1')) {
      const id = 'apt-1';
      const name = 'Dr. Sarah';
      const time = '10:00';
      const period = 'AM';
      final delay = AppointmentDelayStore.entryFor(id);
      final isDelayed = delay != null;
      cards.add(
        _buildAppointmentCard(
          imageUrl: _defaultImage,
          name: name,
          specialty: 'Dental Surgeon',
          time: time,
          period: period,
          status: isDelayed ? 'DELAYED' : 'ON TIME',
          statusColor: isDelayed ? Colors.orange : Colors.green,
          statusText: isDelayed ? delay!.statusLine : 'Schedule is clear',
          locationInfo: isDelayed ? 'Doctor Location:' : 'Doctor is ',
          locationStatus: isDelayed ? 'En Route' : 'At Clinic',
          locationIcon:
              isDelayed ? Icons.directions_car_rounded : Icons.domain_rounded,
          recommendText: isDelayed ? 'Recommended Arrival:' : null,
          recommendTime: isDelayed ? delay!.recommendedArrivalDisplay : null,
          accentColor: isDelayed ? Colors.orange : Colors.green,
          isDelayed: isDelayed,
          appointmentId: id,
          onDoctorNotifyDelay: doctorMode
              ? () => _openNotifyDelaySheet(
                    appointmentId: id,
                    doctorName: name,
                    time: time,
                    period: period,
                  )
              : null,
          onCancel: () => _showCancelConfirm(
            context,
            id,
            true,
            doctorName: name,
            dayLabel: 'Today',
            timeSlot: '$time $period',
          ),
          hideClinicLocationRow: widget.showDoctorAppBar,
        ),
      );
    }
    if (!SessionBookingsStore.isMockCancelled('apt-2')) {
      const id = 'apt-2';
      const name = 'Dr. Alyson';
      const time = '02:30';
      const period = 'PM';
      final delay = AppointmentDelayStore.entryFor(id);
      final isDelayed = delay != null;
      cards.add(
        _buildAppointmentCard(
          imageUrl: _defaultImage,
          name: name,
          specialty: 'Dermatologist',
          time: time,
          period: period,
          status: isDelayed ? 'DELAYED' : 'ON TIME',
          statusColor: isDelayed ? Colors.orange : Colors.green,
          statusText: isDelayed ? delay!.statusLine : 'Schedule is clear',
          locationInfo: isDelayed ? 'Doctor Location:' : 'Doctor is ',
          locationStatus: isDelayed ? 'En Route' : 'At Clinic',
          locationIcon:
              isDelayed ? Icons.directions_car_rounded : Icons.domain_rounded,
          recommendText: isDelayed ? 'Recommended Arrival:' : null,
          recommendTime: isDelayed ? delay!.recommendedArrivalDisplay : null,
          accentColor: isDelayed ? Colors.orange : Colors.green,
          isDelayed: isDelayed,
          appointmentId: id,
          onDoctorNotifyDelay: doctorMode
              ? () => _openNotifyDelaySheet(
                    appointmentId: id,
                    doctorName: name,
                    time: time,
                    period: period,
                  )
              : null,
          onCancel: () => _showCancelConfirm(
            context,
            id,
            true,
            doctorName: name,
            dayLabel: 'Today',
            timeSlot: '$time $period',
          ),
          hideClinicLocationRow: widget.showDoctorAppBar,
        ),
      );
    }
    for (final b in SessionBookingsStore.getTodayBookings()) {
      final slot = b['time_slot'] as String? ?? '';
      final (time, period) = SessionBookingsStore.parseTimeSlot(slot);
      final id = b['id'] as String? ?? '';
      final docName = b['doctor_name'] as String? ?? 'Doctor';
      final delay = AppointmentDelayStore.entryFor(id);
      final isDelayed = delay != null;
      cards.add(
        _buildAppointmentCard(
          imageUrl: _defaultImage,
          name: docName,
          specialty: b['specialty'] as String? ?? 'Consultation',
          time: time,
          period: period,
          status: isDelayed ? 'DELAYED' : 'CONFIRMED',
          statusColor: isDelayed ? Colors.orange : const Color(0xFF1E88E5),
          statusText:
              isDelayed ? delay!.statusLine : 'Confirmed',
          locationInfo: isDelayed ? 'Doctor Location:' : 'Doctor is ',
          locationStatus: isDelayed ? 'En Route' : 'At Clinic',
          locationIcon:
              isDelayed ? Icons.directions_car_rounded : Icons.domain_rounded,
          recommendText: isDelayed ? 'Recommended Arrival:' : null,
          recommendTime: isDelayed ? delay!.recommendedArrivalDisplay : null,
          accentColor: isDelayed ? Colors.orange : const Color(0xFF1E88E5),
          isDelayed: isDelayed,
          appointmentId: id,
          onDoctorNotifyDelay: doctorMode
              ? () => _openNotifyDelaySheet(
                    appointmentId: id,
                    doctorName: docName,
                    time: time,
                    period: period,
                  )
              : null,
          onCancel: () => _showCancelConfirm(context, id, false),
          hideClinicLocationRow: widget.showDoctorAppBar,
        ),
      );
    }
    return cards;
  }

  /// Doctor "Today's Appointments": same card chrome, patient name/avatar, visit line.
  List<Widget> _buildDoctorTodayPatientCards() {
    final cards = <Widget>[];

    for (final m in _doctorTodayPreviewMocks) {
      final id = m['id']!;
      if (SessionBookingsStore.isMockCancelled(id)) continue;

      final patientName = m['patientName']!;
      final imageUrl = m['imageUrl']!;
      final visitType = m['visitType']!;
      final time = m['time']!;
      final period = m['period']!;
      final notifyAsDoctor = m['notifyAsDoctor']!;

      final delay = AppointmentDelayStore.entryFor(id);
      final isDelayed = delay != null;

      cards.add(
        _buildAppointmentCard(
          imageUrl: imageUrl,
          name: patientName,
          specialty: visitType,
          time: time,
          period: period,
          status: isDelayed ? 'DELAYED' : 'ON TIME',
          statusColor: isDelayed ? Colors.orange : Colors.green,
          statusText: isDelayed ? delay!.statusLine : 'Schedule is clear',
          locationInfo: isDelayed ? 'Doctor Location:' : 'Doctor is ',
          locationStatus: isDelayed ? 'En Route' : 'At Clinic',
          locationIcon: isDelayed
              ? Icons.directions_car_rounded
              : Icons.domain_rounded,
          recommendText: isDelayed ? 'Recommended Arrival:' : null,
          recommendTime: isDelayed ? delay!.recommendedArrivalDisplay : null,
          accentColor: isDelayed ? Colors.orange : Colors.green,
          isDelayed: isDelayed,
          appointmentId: id,
          onDoctorNotifyDelay: () => _openNotifyDelaySheet(
                appointmentId: id,
                doctorName: notifyAsDoctor,
                time: time,
                period: period,
              ),
          onCancel: () => _showCancelConfirm(
                context,
                id,
                true,
                doctorName: notifyAsDoctor,
                dayLabel: 'Today',
                timeSlot: '$time $period',
              ),
          hideClinicLocationRow: true,
        ),
      );
    }

    for (final b
        in SessionBookingsStore.getTodayBookingsForDoctor(DoctorSession.currentDoctorId)) {
      final slot = b['time_slot'] as String? ?? '';
      final (time, period) = SessionBookingsStore.parseTimeSlot(slot);
      final id = b['id'] as String? ?? '';
      final patientName = b['patient_name'] as String? ?? 'Patient';
      final notifyAsDoctor =
          b['doctor_name'] as String? ?? DoctorSession.displayName;
      final delay = AppointmentDelayStore.entryFor(id);
      final isDelayed = delay != null;

      cards.add(
        _buildAppointmentCard(
          imageUrl: _defaultImage,
          name: patientName,
          specialty: b['specialty'] as String? ?? 'Consultation',
          time: time,
          period: period,
          status: isDelayed ? 'DELAYED' : 'CONFIRMED',
          statusColor: isDelayed ? Colors.orange : const Color(0xFF1E88E5),
          statusText: isDelayed ? delay!.statusLine : 'Confirmed',
          locationInfo: isDelayed ? 'Doctor Location:' : 'Doctor is ',
          locationStatus: isDelayed ? 'En Route' : 'At Clinic',
          locationIcon: isDelayed
              ? Icons.directions_car_rounded
              : Icons.domain_rounded,
          recommendText: isDelayed ? 'Recommended Arrival:' : null,
          recommendTime: isDelayed ? delay!.recommendedArrivalDisplay : null,
          accentColor: isDelayed ? Colors.orange : const Color(0xFF1E88E5),
          isDelayed: isDelayed,
          appointmentId: id,
          onDoctorNotifyDelay: () => _openNotifyDelaySheet(
                appointmentId: id,
                doctorName: notifyAsDoctor,
                time: time,
                period: period,
              ),
          onCancel: () => _showCancelConfirm(context, id, false),
          hideClinicLocationRow: true,
        ),
      );
    }

    return cards;
  }

  List<Widget> _buildUpcomingCards() {
    const primaryColor = Color(0xFF1E88E5);
    final cards = <Widget>[];
    final doctorMode = widget.showDoctorAppBar;

    if (!SessionBookingsStore.isMockCancelled('up-1')) {
      const id = 'up-1';
      const doc = 'Dr. James';
      const slot = '09:00 AM';
      cards.add(
        _buildUpcomingCard(
          'Oct',
          '24',
          doc,
          'Cardiologist • City Heart Center',
          slot,
          'Video Call',
          Icons.videocam_rounded,
          const Color(0xFF6366F1),
          appointmentId: id,
          delay: AppointmentDelayStore.entryFor(id),
          onDoctorNotifyDelay: doctorMode
              ? () => _openNotifyDelaySheet(
                    appointmentId: id,
                    doctorName: doc,
                    time12hLabel: slot,
                  )
              : null,
          onCancel: () => _showCancelConfirm(
            context,
            id,
            true,
            doctorName: doc,
            dayLabel: 'Oct 24',
            timeSlot: slot,
          ),
        ),
      );
    }
    if (!SessionBookingsStore.isMockCancelled('up-2')) {
      const id = 'up-2';
      const doc = 'Dr. Michael';
      const slot = '11:30 AM';
      cards.add(
        _buildUpcomingCard(
          'Nov',
          '02',
          doc,
          'Neurologist • Neuro Care Clinic',
          slot,
          'In-Person',
          Icons.location_on_rounded,
          const Color(0xFF636388),
          appointmentId: id,
          delay: AppointmentDelayStore.entryFor(id),
          onDoctorNotifyDelay: doctorMode
              ? () => _openNotifyDelaySheet(
                    appointmentId: id,
                    doctorName: doc,
                    time12hLabel: slot,
                  )
              : null,
          onCancel: () => _showCancelConfirm(
            context,
            id,
            true,
            doctorName: doc,
            dayLabel: 'Nov 02',
            timeSlot: slot,
          ),
        ),
      );
    }
    for (final b in SessionBookingsStore.getUpcomingBookings()) {
      final dateStr = b['date'] as String? ?? '';
      final parts = dateStr.split('-');
      String month = 'Jan';
      String day = '01';
      if (parts.length >= 3) {
        final m = int.tryParse(parts[1]) ?? 1;
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        month = months[m < 1 || m > 12 ? 0 : m - 1];
        day = parts[2];
      }
      final id = b['id'] as String? ?? '';
      final docName = b['doctor_name'] as String? ?? 'Doctor';
      final slot = b['time_slot'] as String? ?? '';
      cards.add(
        _buildUpcomingCard(
          month,
          day,
          docName,
          '${b['specialty'] ?? 'Consultation'} • Booking',
          slot,
          'In-Person',
          Icons.location_on_rounded,
          primaryColor,
          appointmentId: id,
          delay: AppointmentDelayStore.entryFor(id),
          onDoctorNotifyDelay: doctorMode
              ? () => _openNotifyDelaySheet(
                    appointmentId: id,
                    doctorName: docName,
                    time12hLabel: slot,
                  )
              : null,
          onCancel: () => _showCancelConfirm(context, id, false),
        ),
      );
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const surfaceColor = Color(0xFFF5F7FA);
    final todayCards = _buildTodayCards();
    final todayOnly = widget.todayOnlyView;
    final showBookBtn = widget.showBookAppointmentButton;
    final listBottomPadding =
        (todayOnly || !showBookBtn) ? 24.0 : 100.0;

    final showAppBar = widget.showDoctorAppBar;
    final appBarTitle = widget.todayOnlyView
        ? "Today's Appointments"
        : 'Patient Bookings';

    final listChildren = <Widget>[
      if (!showAppBar) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Appointments",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${todayCards.length}',
                  style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ] else
        const SizedBox(height: 8),
      if (todayCards.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              todayOnly
                  ? 'No appointments scheduled for today.'
                  : 'No appointments today.',
              style: const TextStyle(
                color: Color(0xFF636388),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      else
        ...todayCards.expand((c) => [c, const SizedBox(height: 16)]).toList()
          ..removeLast(),
    ];

    if (!todayOnly) {
      listChildren.addAll([
        const SizedBox(height: 32),
        const Text(
          "Upcoming Appointments",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor),
        ),
        const SizedBox(height: 16),
        ...() {
          final upcoming = _buildUpcomingCards();
          return upcoming.expand((c) => [c, const SizedBox(height: 16)]).toList()
            ..removeLast();
        }(),
      ]);
    }

    final body = Container(
      color: surfaceColor,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, listBottomPadding),
            children: listChildren,
          ),
          if (!todayOnly && showBookBtn)
            Positioned(
              left: 20,
              right: 20,
              bottom: 32,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllSpecialtiesScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 24),
                      SizedBox(width: 8),
                      Text('Book a New Appointment',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (!showAppBar) return body;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${todayCards.length}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildAppointmentCard({
    required String imageUrl,
    required String name,
    required String specialty,
    required String time,
    required String period,
    required String status,
    required Color statusColor,
    required String statusText,
    required String locationInfo,
    required String locationStatus,
    required IconData locationIcon,
    required Color accentColor,
    bool isDelayed = false,
    String? recommendText,
    String? recommendTime,
    String? appointmentId,
    VoidCallback? onDoctorNotifyDelay,
    VoidCallback? onCancel,
    bool hideClinicLocationRow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: statusColor, width: 8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        image: DecorationImage(
                            image: NetworkImage(imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF111118))),
                      Text(specialty,
                          style: const TextStyle(
                              color: Color(0xFF636388), fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                              isDelayed
                                  ? Icons.error_outline_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: statusColor,
                              size: 16),
                          const SizedBox(width: 4),
                          Text(statusText,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
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
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(time,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      Text(period,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
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
              children: [
                if (!hideClinicLocationRow)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(locationIcon,
                              color: const Color(0xFF94A3B8), size: 18),
                          const SizedBox(width: 8),
                          Text(locationInfo,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF636388))),
                          if (!isDelayed) ...[
                            const SizedBox(width: 4),
                            Text(locationStatus,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                      if (isDelayed)
                        Row(
                          children: [
                            Text(locationStatus,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111118))),
                            const SizedBox(width: 6),
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle)),
                          ],
                        )
                      else
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1E88E5),
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Directions',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                if (isDelayed && recommendText != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.update_rounded,
                              color: Color(0xFF94A3B8), size: 18),
                          const SizedBox(width: 8),
                          Text(recommendText,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF636388))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE))),
                        child: Text(recommendTime!,
                            style: const TextStyle(
                                color: Color(0xFF1E88E5),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
                if (onDoctorNotifyDelay != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onDoctorNotifyDelay,
                      icon: const Icon(Icons.schedule_send_rounded, size: 20),
                      label: const Text('Notify delay'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFEA580C),
                        side: const BorderSide(color: Color(0xFFFDBA74)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                if (onCancel != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel appointment'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(
    String month,
    String day,
    String name,
    String details,
    String time,
    String type,
    IconData typeIcon,
    Color typeColor, {
    String? appointmentId,
    AppointmentDelayEntry? delay,
    VoidCallback? onDoctorNotifyDelay,
    VoidCallback? onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: delay != null
            ? const Border(
                left: BorderSide(color: Color(0xFFEA580C), width: 8),
              )
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (delay != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade800, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'DELAYED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.orange.shade900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                    'Recommended arrival: ${delay.recommendedArrivalDisplay}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(month,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5))),
                    Text(day,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF111118))),
                        const Icon(Icons.more_horiz_rounded,
                            color: Color(0xFF94A3B8), size: 24),
                      ],
                    ),
                    Text(details,
                        style: const TextStyle(
                            color: Color(0xFF636388), fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildUpcomingTag(Icons.schedule_rounded, time,
                            const Color(0xFFF1F5F9), const Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        _buildUpcomingTag(typeIcon, type,
                            typeColor.withOpacity(0.1), typeColor),
                        if (delay != null) ...[
                          const SizedBox(width: 8),
                          _buildUpcomingTag(
                            Icons.schedule_send_rounded,
                            'Delayed',
                            const Color(0xFFFFEDD5),
                            const Color(0xFFEA580C),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onDoctorNotifyDelay != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDoctorNotifyDelay,
                icon: const Icon(Icons.schedule_send_rounded, size: 20),
                label: const Text('Notify delay'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFEA580C),
                  side: const BorderSide(color: Color(0xFFFDBA74)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel appointment'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingTag(
      IconData icon, String label, Color bgColor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
