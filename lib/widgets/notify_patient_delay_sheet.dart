import 'package:flutter/material.dart';

import '../services/appointment_delay_store.dart';
import '../services/notifications_store.dart';

/// Shared bottom sheet: doctor notifies patients of a delay (local/mock).
Future<void> showNotifyPatientDelaySheet(
  BuildContext context, {
  required String appointmentId,
  required String doctorName,
  String? time,
  String? period,
  String? time12hLabel,
  VoidCallback? onSuccess,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return NotifyPatientDelaySheetBody(
        doctorName: doctorName,
        onSubmit: (minutes, note) {
          if (time12hLabel != null) {
            AppointmentDelayStore.setDelayFromTimeLabel(
              appointmentId: appointmentId,
              minutesLate: minutes,
              doctorName: doctorName,
              time12hLabel: time12hLabel,
              note: note,
            );
          } else if (time != null && period != null) {
            AppointmentDelayStore.setDelay(
              appointmentId: appointmentId,
              minutesLate: minutes,
              doctorName: doctorName,
              time: time,
              period: period,
              note: note,
            );
          }
          NotificationsStore.addDelayNotification(
            doctorName: doctorName,
            minutesLate: minutes,
            note: note,
          );
          onSuccess?.call();
        },
      );
    },
  );
}

class NotifyPatientDelaySheetBody extends StatefulWidget {
  const NotifyPatientDelaySheetBody({
    super.key,
    required this.doctorName,
    required this.onSubmit,
  });

  final String doctorName;
  final void Function(int minutes, String? note) onSubmit;

  @override
  State<NotifyPatientDelaySheetBody> createState() =>
      _NotifyPatientDelaySheetBodyState();
}

class _NotifyPatientDelaySheetBodyState extends State<NotifyPatientDelaySheetBody> {
  int _selectedMinutes = 15;
  final TextEditingController _customMinutes = TextEditingController();
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _customMinutes.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Notify patients of delay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111118),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Patients booked with ${widget.doctorName} will see an update and get a notification.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF636388),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Delay duration',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF111118),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [10, 15, 20].map((m) {
              final selected =
                  _customMinutes.text.isEmpty && _selectedMinutes == m;
              return FilterChip(
                label: Text('$m min'),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedMinutes = m;
                    _customMinutes.clear();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customMinutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Custom minutes',
              hintText: 'e.g. 25',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Message to patients (optional)',
              hintText: 'e.g. Running late — thank you for your patience',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              final custom = int.tryParse(_customMinutes.text.trim());
              final minutes =
                  (custom != null && custom > 0) ? custom : _selectedMinutes;
              if (minutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid delay in minutes'),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              widget.onSubmit(
                minutes,
                _note.text.trim().isEmpty ? null : _note.text.trim(),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Send update'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
