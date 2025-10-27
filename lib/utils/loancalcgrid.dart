import 'package:flutter/material.dart';
import '../screens/loan_calculator/emi_calc.dart';
import '../screens/loan_calculator/home_loan_calc.dart';
import '../screens/loan_calculator/loan_prepay_calc.dart';

Widget buildCalculatorGrid(BuildContext context) {
  final calculators = [
    CalculatorItem(
      icon: Icons.trending_up,
      title: 'EMI Calculator',
      subtitle: 'Calculate EMIs for all types of loan',
      color: Colors.cyan.shade400,
      gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
      route: const EMICalculator(),
    ),
    CalculatorItem(
      icon: Icons.home,
      title: 'Mortgage',
      subtitle: 'Home Loans',
      color: Colors.blue.shade400,
      gradient: [Colors.blue.shade400, Colors.blue.shade600],
      route: const HomeLoanCalculator(),
    ),
    CalculatorItem(
      icon: Icons.auto_fix_high,
      title: 'Loan Prepayment',
      subtitle: 'Techniques to save interest and finish loan faster',
      color: Colors.green.shade400,
      gradient: [Colors.green.shade400, Colors.green.shade600],
      route: const LoanPrepaymentCalculator(),
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
            color: Colors.black.withOpacity(0.05),
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
