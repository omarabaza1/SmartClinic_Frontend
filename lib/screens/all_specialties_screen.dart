import 'package:flutter/material.dart';
import 'select_specialty_3.dart';

/// Screen showing all specialties in one list (opened from "View All").
class AllSpecialtiesScreen extends StatelessWidget {
  const AllSpecialtiesScreen({super.key});

  static const List<Map<String, dynamic>> _allSpecialties = [
    {'title': 'Dermatology', 'subtitle': 'Skin, Hair & Nails', 'icon': Icons.face, 'color': 0xFF1E88E5, 'bgColor': 0xFFE3F2FD},
    {'title': 'Dentistry', 'subtitle': 'Teeth & Oral Health', 'icon': Icons.medical_services, 'color': 0xFF0D9488, 'bgColor': 0xFFE0F2F1},
    {'title': 'Psychiatry', 'subtitle': 'Mental Health', 'icon': Icons.psychology, 'color': 0xFF4F46E5, 'bgColor': 0xFFEDE7F6},
    {'title': 'Pediatrics', 'subtitle': 'Child & Infant Care', 'icon': Icons.child_care, 'color': 0xFFEA580C, 'bgColor': 0xFFFFF3E0},
    {'title': 'Gynaecology', 'subtitle': "Women's Health", 'icon': Icons.pregnant_woman, 'color': 0xFFDB2777, 'bgColor': 0xFFFCE4EC},
    {'title': 'Ear, Nose & Throat', 'subtitle': 'ENT Specialist', 'icon': Icons.hearing, 'color': 0xFF0284C7, 'bgColor': 0xFFE1F5FE},
    {'title': 'Cardiology', 'subtitle': 'Heart & Vascular', 'icon': Icons.favorite, 'color': 0xFFDC2626, 'bgColor': 0xFFFFEBEE},
    {'title': 'Orthopedics', 'subtitle': 'Bone & Joint', 'icon': Icons.accessible, 'color': 0xFF65A30D, 'bgColor': 0xFFF0FDF4},
    {'title': 'Neurology', 'subtitle': 'Brain & Nerves', 'icon': Icons.psychology_outlined, 'color': 0xFF7C3AED, 'bgColor': 0xFFF5F3FF},
    {'title': 'View All Specialties', 'subtitle': '120+ categories', 'icon': Icons.more_horiz, 'color': 0xFF64748B, 'bgColor': 0xFFF5F7FA},
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'All Specialties',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _allSpecialties.length,
        itemBuilder: (context, index) {
          final s = _allSpecialties[index];
          final title = s['title'] as String;
          final subtitle = s['subtitle'] as String;
          final icon = s['icon'] as IconData;
          final color = Color(s['color'] as int);
          final bgColor = Color(s['bgColor'] as int);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF636388), fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD1D5DB), size: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectSpecialty3Screen(
                        selectedSpecialty: title == 'View All Specialties' ? null : title,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
