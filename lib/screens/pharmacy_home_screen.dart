import 'package:flutter/material.dart';
import 'pharmacy_category_screen.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const surfaceColor = Color(0xFFF5F7FA);

    final categories = [
      {
        'name': 'Featured',
        'image':
            'https://images.unsplash.com/photo-1584308666744-24d5c474f26b?auto=format&fit=crop&q=80',
        'color': const Color(0xFFE3F2FD)
      },
      {
        'name': 'Korean Products',
        'image':
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&q=80',
        'color': const Color(0xFFE8F5E9)
      },
      {
        'name': 'Prescription',
        'image':
            'https://images.unsplash.com/photo-1576091160550-217359f41f48?auto=format&fit=crop&q=80',
        'color': const Color(0xFFFFF3E0)
      },
      {
        'name': 'Vitamins',
        'image':
            'https://images.unsplash.com/photo-1550573105-75864e3bc247?auto=format&fit=crop&q=80',
        'color': const Color(0xFFFFFDE7)
      },
      {
        'name': 'Baby Care',
        'image':
            'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&q=80',
        'color': const Color(0xFFFCE4EC)
      },
      {
        'name': 'First Aid',
        'image':
            'https://images.unsplash.com/photo-1603398938378-e54eab446ddd?auto=format&fit=crop&q=80',
        'color': const Color(0xFFEFEBE9)
      },
      {
        'name': 'Pain Relief',
        'image':
            'https://images.unsplash.com/photo-1585435557343-3b092031a831?auto=format&fit=crop&q=80',
        'color': const Color(0xFFF3E5F5)
      },
      {
        'name': 'Cold & Flu',
        'image':
            'https://images.unsplash.com/photo-1584017945516-72436f9872be?auto=format&fit=crop&q=80',
        'color': const Color(0xFFE0F7FA)
      },
      {
        'name': 'Digestion',
        'image':
            'https://images.unsplash.com/photo-1512428559087-560fa5ceab42?auto=format&fit=crop&q=80',
        'color': const Color(0xFFF1F8E9)
      },
      {
        'name': 'Skin Care',
        'image':
            'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&q=80',
        'color': const Color(0xFFFCE4EC)
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 40),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pharmacy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const Text('Find your medicines',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search medicines, categories...',
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey[400], size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Browse by Category',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All',
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PharmacyCategoryScreen()),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: cat['color'] as Color,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          cat['image'] as String,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    if (cat['name'] == 'Featured')
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(24),
                                                bottomRight:
                                                    Radius.circular(8)),
                                          ),
                                          child: const Icon(Icons.percent,
                                              color: Colors.white, size: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
