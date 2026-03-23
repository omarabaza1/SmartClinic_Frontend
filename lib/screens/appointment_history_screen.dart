import 'package:flutter/material.dart';
import '../services/appointment_history_store.dart';

enum _FilterOption { all, booked, completed, cancelled }

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  _FilterOption _filter = _FilterOption.all;

  @override
  void initState() {
    super.initState();
    AppointmentHistoryStore.version.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    AppointmentHistoryStore.version.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _allItems =>
      AppointmentHistoryStore.getEntries();

  List<Map<String, dynamic>> get _filteredItems {
    if (_filter == _FilterOption.all) return _allItems;
    final status = _filter.name;
    return _allItems.where((e) => (e['status'] as String?) == status).toList();
  }

  static const _primaryColor = Color(0xFF1E88E5);
  static const _textColor = Color(0xFF111118);
  static const _grayText = Color(0xFF636388);
  static const _surfaceColor = Color(0xFFF5F7FA);
  static const _defaultImage =
      'https://cdn-icons-png.flaticon.com/512/3774/3774299.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Appointment History',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildFilterChips(),
                const SizedBox(height: 24),
                Expanded(
                  child: _filteredItems.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildChip('All', _FilterOption.all),
          const SizedBox(width: 10),
          _buildChip('Booked', _FilterOption.booked),
          const SizedBox(width: 10),
          _buildChip('Completed', _FilterOption.completed),
          const SizedBox(width: 10),
          _buildChip('Cancelled', _FilterOption.cancelled),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildChip(String label, _FilterOption option) {
    final selected = _filter == option;
    return Material(
      color: selected ? _primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => setState(() => _filter = option),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _primaryColor : const Color(0xFFE2E8F0),
            ),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _grayText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: _grayText,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _filter == _FilterOption.all
                  ? 'Book an appointment to see it here.'
                  : 'No ${_filter.name} appointments yet.',
              style: const TextStyle(
                fontSize: 14,
                color: _grayText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in _filteredItems) {
      final date = item['date'] as String? ?? '';
      final section = _sectionHeaderForDate(date);
      grouped.putIfAbsent(section, () => []).add(item);
    }
    for (final list in grouped.values) {
      list.sort((a, b) =>
          (b['date'] as String? ?? '').compareTo((a['date'] as String? ?? '')));
    }
    final sections = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: sections.fold<int>(0, (sum, s) => sum + 1 + grouped[s]!.length),
      itemBuilder: (context, index) {
        int i = 0;
        for (final section in sections) {
          if (index == i) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                section,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _grayText,
                  letterSpacing: 0.2,
                ),
              ),
            );
          }
          i++;
          for (final item in grouped[section]!) {
            if (index == i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryCard(item),
              );
            }
            i++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _sectionHeaderForDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length < 3) return 'Other';
    final y = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = m >= 1 && m <= 12 ? months[m - 1] : 'Month';
    return '$month $y';
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final status = (item['status'] as String?) ?? 'booked';
    final badge = _statusBadge(status);
    final isBooked = status == 'booked';
    final id = item['id'] as String?;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  image: const DecorationImage(
                    image: NetworkImage(_defaultImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['doctor_name'] as String? ?? 'Doctor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['specialty'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _grayText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14, color: _grayText.withOpacity(0.8)),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(item['date'] as String?),
                          style: const TextStyle(
                            fontSize: 12,
                            color: _grayText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 14, color: _grayText.withOpacity(0.8)),
                        const SizedBox(width: 6),
                        Text(
                          item['time_slot'] as String? ?? '--',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _grayText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              badge,
            ],
          ),
          if (isBooked && id != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  AppointmentHistoryStore.markCompleted(id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as completed'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Mark as completed'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF059669),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '--';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = m >= 1 && m <= 12 ? months[m - 1] : '--';
    return '$month $d';
  }

  Widget _statusBadge(String status) {
    String label;
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'booked':
        label = 'Booked';
        bgColor = const Color(0xFFEFF6FF);
        textColor = _primaryColor;
        break;
      case 'completed':
        label = 'Completed';
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF059669);
        break;
      case 'cancelled':
        label = 'Cancelled';
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        label = status;
        bgColor = const Color(0xFFF1F5F9);
        textColor = _grayText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
