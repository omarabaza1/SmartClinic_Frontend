import 'package:flutter/material.dart';

class AISelfCheckupScreen extends StatelessWidget {
  const AISelfCheckupScreen({super.key});

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
        title: const Text(
          'AI Self-Checkup',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disclaimer Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(24),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFF59E0B), width: 6),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Disclaimer',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: 'This AI checkup '),
                                    TextSpan(
                                      text: 'does not replace a doctor',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            '. It is for informational purposes only. Always consult a specialist for professional diagnosis.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Select a condition',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose an area to analyze specifically.',
                    style: TextStyle(
                      color: grayText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildConditionCard(
                        icon: Icons.favorite,
                        color: Colors.red,
                        bgColor: const Color(0xFFFEF2F2),
                        title: 'Heart Health',
                        subtitle: 'Arrhythmia & pulse check',
                      ),
                      _buildConditionCard(
                        icon: Icons.water_drop,
                        color: Colors.blue,
                        bgColor: const Color(0xFFEFF6FF),
                        title: 'Diabetes Risk',
                        subtitle: 'Glucose level inputs',
                      ),
                      _buildConditionCard(
                        icon: Icons.thermostat,
                        color: Colors.orange,
                        bgColor: const Color(0xFFFFF7ED),
                        title: 'Fever',
                        subtitle: 'Temperature & symptoms',
                      ),
                      _buildConditionCard(
                        icon: Icons.speed,
                        color: Colors.purple,
                        bgColor: const Color(0xFFFAF5FF),
                        title: 'Hypertension',
                        subtitle: 'BP monitor log',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildConditionCard(
                    icon: Icons.psychology,
                    color: Colors.indigo,
                    bgColor: const Color(0xFFEEF2FF),
                    title: 'Consciousness',
                    subtitle: 'Mental state & awareness check',
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Start General Assessment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    bool isFullWidth = false,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111118),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF636388),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
