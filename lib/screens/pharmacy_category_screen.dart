import 'package:flutter/material.dart';

class PharmacyCategoryScreen extends StatelessWidget {
  const PharmacyCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Vitamins',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildHeaderChip('All Items', true),
                      const SizedBox(width: 12),
                      _buildHeaderChip('Immunity Boost', false),
                      const SizedBox(width: 12),
                      _buildHeaderChip('Bone Health', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: grayText, fontSize: 14),
                        children: [
                          TextSpan(
                              text: 'Found ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          TextSpan(
                              text: '24 Results',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildToolBtn(Icons.tune_rounded),
                        const SizedBox(width: 12),
                        _buildToolBtn(Icons.grid_view_rounded),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                  children: [
                    _buildProductCard(
                      'Vitamin C 1000mg',
                      '60 Tablets • Immunity',
                      12.50,
                      'https://cdn-icons-png.flaticon.com/512/5903/5903272.png',
                      const Color(0xFFFFF7ED),
                      tag: 'Best Seller',
                      tagColor: Colors.orange,
                    ),
                    _buildProductCard(
                      'Calcium + D3',
                      '30 Tablets • Bone Health',
                      8.90,
                      'https://cdn-icons-png.flaticon.com/512/3233/3233835.png',
                      const Color(0xFFEFF6FF),
                    ),
                    _buildProductCard(
                      'Multivitamins Daily',
                      '90 Capsules • General',
                      18.70,
                      'https://cdn-icons-png.flaticon.com/512/2965/2965152.png',
                      const Color(0xFFF0FDF4),
                      discount: '-15%',
                    ),
                    _buildProductCard(
                      'Vitamin B12',
                      '60 Tablets • Energy',
                      15.00,
                      'https://cdn-icons-png.flaticon.com/512/4601/4601556.png',
                      const Color(0xFFFEF2F2),
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

  Widget _buildHeaderChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1E88E5) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildToolBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Icon(icon, color: const Color(0xFF636388), size: 20),
    );
  }

  Widget _buildProductCard(
    String name,
    String details,
    double price,
    String imageUrl,
    Color bgColor, {
    String? tag,
    Color? tagColor,
    String? discount,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(18)),
              child: Stack(
                children: [
                  if (discount != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(discount,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.favorite_border_rounded,
                        color: Color(0xFF636388), size: 20),
                  ),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.network(imageUrl))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (tag != null) ...[
            Text(tag,
                style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
          ],
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF111118)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(details,
              style: const TextStyle(color: Color(0xFF636388), fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
