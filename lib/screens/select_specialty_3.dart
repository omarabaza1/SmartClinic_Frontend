import 'package:flutter/material.dart';
import 'select_specialty_1.dart';

class SelectSpecialty3Screen extends StatefulWidget {
  final String? initialSearchQuery;
  /// When coming from Clinic Visit → specialty list, only doctors in this specialty are shown.
  final String? selectedSpecialty;

  const SelectSpecialty3Screen({super.key, this.initialSearchQuery, this.selectedSpecialty});

  @override
  State<SelectSpecialty3Screen> createState() => _SelectSpecialty3ScreenState();
}

class _SelectSpecialty3ScreenState extends State<SelectSpecialty3Screen> {
  late final TextEditingController _searchController;

  static final List<Map<String, dynamic>> _allDoctors = [
    {'id': 'dr-1', 'name': 'Dr. Sarah Johnson', 'specialty': 'Dermatology', 'title': 'Dermatology & Laser Consultant', 'rating': 4.8, 'reviews': 120, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Dermatology specialized in Adult Dermatology, Pediatric Dermatology, Cosmetic Dermatology...', 'location': 'Nasr City : Ali Ameen _Moustafa El Nahas', 'fees': '500 EGP', 'nextAvailable': 'Tomorrow, 1:00 PM', 'isToday': false, 'isOnline': true},
    {'id': 'dr-2', 'name': 'Dr. Maher Mahmoud', 'specialty': 'Dermatology', 'title': 'Specialist in dermatology, cosmetic...', 'rating': 5.0, 'reviews': 89, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Specialist in Adult Dermatology, Pediatric Dermatology, Laser Therapy...', 'location': "Maadi: Road 9, Next to McDonald's", 'fees': '450 EGP', 'nextAvailable': 'Today, 6:00 PM', 'isToday': true, 'isOnline': true},
    {'id': 'dr-3', 'name': 'Dr. James Wilson', 'specialty': 'Cardiology', 'title': 'Cardiologist & Heart Specialist', 'rating': 4.9, 'reviews': 156, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Expert in cardiovascular diseases, ECG, and preventive care.', 'location': 'City Heart Center, Downtown', 'fees': '600 EGP', 'nextAvailable': 'Monday, 9:00 AM', 'isToday': false, 'isOnline': true},
    {'id': 'dr-4', 'name': 'Dr. Emily Chen', 'specialty': 'Dentistry', 'title': 'Dental Surgeon & Orthodontics', 'rating': 4.7, 'reviews': 98, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'General dentistry, teeth cleaning, and orthodontic treatments.', 'location': 'Dental Care Clinic, Heliopolis', 'fees': '350 EGP', 'nextAvailable': 'Today, 3:00 PM', 'isToday': true, 'isOnline': false},
    {'id': 'dr-5', 'name': 'Dr. Michael Brown', 'specialty': 'Neurology', 'title': 'Neurologist', 'rating': 4.8, 'reviews': 72, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Headaches, migraines, and neurological disorders.', 'location': 'Neuro Care Clinic, Maadi', 'fees': '550 EGP', 'nextAvailable': 'Tomorrow, 11:00 AM', 'isToday': false, 'isOnline': true},
    {'id': 'dr-6', 'name': 'Dr. Ahmed Hassan', 'specialty': 'Pediatrics', 'title': 'Pediatrician', 'rating': 4.9, 'reviews': 134, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Child health, vaccinations, and growth monitoring.', 'location': 'Kids Care Hospital, Nasr City', 'fees': '400 EGP', 'nextAvailable': 'Today, 5:00 PM', 'isToday': true, 'isOnline': true},
    {'id': 'dr-7', 'name': 'Dr. Lisa Park', 'specialty': 'Psychiatry', 'title': 'Psychiatrist', 'rating': 4.6, 'reviews': 65, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Mental health, anxiety, and depression counseling.', 'location': 'Mind Wellness Center', 'fees': '500 EGP', 'nextAvailable': 'Wednesday, 2:00 PM', 'isToday': false, 'isOnline': true},
    {'id': 'dr-8', 'name': 'Dr. Omar Khalil', 'specialty': 'Orthopedics', 'title': 'Orthopedist', 'rating': 4.7, 'reviews': 88, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Bone, joint, and sports injury treatment.', 'location': 'Bone & Joint Clinic', 'fees': '520 EGP', 'nextAvailable': 'Tomorrow, 4:00 PM', 'isToday': false, 'isOnline': false},
    {'id': 'dr-9', 'name': 'Dr. Nora Fathy', 'specialty': 'Gynaecology', 'title': 'Gynaecologist', 'rating': 4.8, 'reviews': 102, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': "Women's health, pregnancy care, and reproductive health.", 'location': 'Women Health Clinic, Dokki', 'fees': '480 EGP', 'nextAvailable': 'Tuesday, 10:00 AM', 'isToday': false, 'isOnline': true},
    {'id': 'dr-10', 'name': 'Dr. Karim Said', 'specialty': 'Ear, Nose & Throat', 'title': 'ENT Specialist', 'rating': 4.7, 'reviews': 76, 'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', 'description': 'Ear, nose, throat and sinus conditions.', 'location': 'ENT Care, Zamalek', 'fees': '420 EGP', 'nextAvailable': 'Today, 4:00 PM', 'isToday': true, 'isOnline': false},
  ];

  List<Map<String, dynamic>> get _filteredDoctors {
    List<Map<String, dynamic>> list = _allDoctors;

    // First filter by selected specialty (when opened from a specialty tap)
    final selected = widget.selectedSpecialty?.trim();
    if (selected != null && selected.isNotEmpty && selected.toLowerCase() != 'view all specialties') {
      final selectedLower = selected.toLowerCase();
      list = list.where((d) {
        final specialty = (d['specialty'] as String).toLowerCase();
        return specialty == selectedLower ||
            specialty.contains(selectedLower) ||
            selectedLower.contains(specialty);
      }).toList();
    }

    // Then filter by search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((d) {
        final name = (d['name'] as String).toLowerCase();
        final specialty = (d['specialty'] as String).toLowerCase();
        final title = (d['title'] as String).toLowerCase();
        return name.contains(query) || specialty.contains(query) || title.contains(query);
      }).toList();
    }
    return list;
  }

  void _onSearchChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery ?? '');
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: textColor),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Column(
                        children: [
                          Text('SEARCHING IN',
                              style: TextStyle(
                                  color: grayText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Cairo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: primaryColor)),
                              Icon(Icons.expand_more,
                                  color: primaryColor, size: 18),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 40), // Spacer for balance
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search doctor or hospital...',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[400], size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFilterBtn(Icons.sort, 'Sort'),
                      const SizedBox(width: 12),
                      _buildFilterBtn(Icons.tune, 'Filter'),
                      const SizedBox(width: 12),
                      _buildFilterBtn(Icons.map_outlined, 'Map'),
                    ],
                  ),
                ],
              ),
            ),
            // Doctor Cards
            Expanded(
              child: _filteredDoctors.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No doctors match "${_searchController.text.trim()}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different specialty or doctor name',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final d = _filteredDoctors[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < _filteredDoctors.length - 1 ? 20 : 0),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectSpecialty1Screen(
                                  doctorId: d['id'] as String?,
                                  doctorName: d['name'] as String?,
                                ),
                              ),
                            ),
                            child: _buildDoctorCard(
                              name: d['name'] as String,
                              title: d['title'] as String,
                              rating: (d['rating'] as num).toDouble(),
                              reviews: d['reviews'] as int,
                              image: d['image'] as String,
                              description: d['description'] as String,
                              location: d['location'] as String,
                              fees: d['fees'] as String,
                              nextAvailable: d['nextAvailable'] as String,
                              isToday: d['isToday'] as bool,
                              isOnline: d['isOnline'] as bool,
                              doctorId: d['id'] as String?,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF1E88E5), size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String title,
    required double rating,
    required int reviews,
    required String image,
    required String description,
    required String location,
    required String fees,
    required String nextAvailable,
    required bool isToday,
    required bool isOnline,
    String? doctorId,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                            image: NetworkImage(image), fit: BoxFit.cover),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF111118))),
                      const SizedBox(height: 4),
                      Text(title,
                          style: const TextStyle(
                              color: Color(0xFF636388), fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                              5,
                              (index) => const Icon(Icons.star,
                                  color: Colors.amber, size: 16)),
                          const SizedBox(width: 4),
                          Text('$rating',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          Text('($reviews reviews)',
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildInfoRow(Icons.medical_services_outlined, description),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on_outlined, location),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.payments_outlined, 'Fees: $fees',
                    isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('NEXT AVAILABLE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8))),
                        const SizedBox(height: 2),
                        Text(nextAvailable,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF1E88E5))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 48,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectSpecialty1Screen(
                            doctorId: doctorId,
                            doctorName: name,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Book',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isBold ? const Color(0xFF111118) : const Color(0xFF636388),
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
