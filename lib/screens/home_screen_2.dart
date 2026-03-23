import 'package:flutter/material.dart';
import 'select_pharmacy_screen.dart';

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);
    const surfaceColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Cart',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('3 items in your cart',
                    style: TextStyle(
                        color: grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                _buildCartItem(
                  'Cough Syrup',
                  '150ml • Mint Flavor',
                  12.50,
                  1,
                  Icons.medication_liquid,
                  const Color(0xFFE3F2FD),
                  const Color(0xFF1E88E5),
                ),
                const SizedBox(height: 16),
                _buildCartItem(
                  'Aspirin 81mg',
                  '30 Tablets • Bayer',
                  8.90,
                  2,
                  Icons.medication,
                  const Color(0xFFE0F2F1),
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 16),
                _buildCartItem(
                  'Digital Thermometer',
                  'Infrared • Non-contact',
                  35.00,
                  1,
                  Icons.thermostat,
                  const Color(0xFFFFF8E1),
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 24),
                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ORDER SUMMARY',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: grayText,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 20),
                      _buildSummaryRow(
                          'Subtotal', '\$65.30', grayText, textColor, false),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                          'Delivery Fee', '\$2.50', grayText, textColor, false),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _buildSummaryRow('Total Amount', '\$67.80', textColor,
                          primaryColor, true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Checkout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SelectPharmacyScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Proceed to Checkout',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          // Bottom Navigation
        ],
      ),
    );
  }

  Widget _buildCartItem(String name, String desc, double price, int qty,
      IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA).withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor.withOpacity(0.6), size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        color: Color(0xFF636388), fontSize: 11)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildQtyBtn(Icons.remove),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          _buildQtyBtn(Icons.add),
                        ],
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

  Widget _buildQtyBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: const Color(0xFF111118)),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color labelColor,
      Color valueColor, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: labelColor,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 20 : 16)),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    if (isActive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home, color: Color(0xFF1E88E5), size: 24),
          ),
          const SizedBox(height: 4),
          const Text('Home',
              style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[400], size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
