import 'package:flutter/material.dart';
import '../screens/coming_soon_screen.dart';

Widget buildCalculatorGrid(BuildContext context) {
  final calculators = [
    CalculatorItem(
      icon: Icons.eco,
      title: 'Lean FIRE',
      subtitle: 'Basic financial independence',
      color: Colors.green.shade400,
      gradient: [Colors.green.shade400, Colors.green.shade600],
      route: const ComingSoonScreen(),
    ),
    CalculatorItem(
      icon: Icons.diamond,
      title: 'Fat FIRE',
      subtitle: 'Plan your retirement luxuriously',
      color: Colors.amber.shade400,
      gradient: [Colors.amber.shade400, Colors.amber.shade600],
      route: const ComingSoonScreen(),
    ),
    CalculatorItem(
      icon: Icons.local_cafe,
      title: 'Barista FIRE',
      subtitle: 'Near-financial freedom',
      color: Colors.brown.shade400,
      gradient: [Colors.brown.shade400, Colors.brown.shade600],
      route: const ComingSoonScreen(),
    ),
    CalculatorItem(
      icon: Icons.beach_access,
      title: 'Coast FIRE',
      subtitle: 'Invest early, retire late',
      color: Colors.teal.shade400,
      gradient: [Colors.teal.shade400, Colors.teal.shade600],
      route: const ComingSoonScreen(),
    ),
  ];

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
    ),
    itemCount: calculators.length,
    itemBuilder: (context, index) {
      return _buildCalculatorCard(context, calculators[index]);
    },
  );
}

Widget _buildCalculatorCard(BuildContext context, CalculatorItem item) {
  return GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${item.title}...'),
          duration: const Duration(seconds: 1),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item.route),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class CalculatorItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradient;
  final Widget route;

  CalculatorItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
    required this.route,
  });
}
