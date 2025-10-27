import 'package:flutter/material.dart';
import '../screens/investment_calculator/sip_calc.dart';
import '../screens/investment_calculator/cagr_calc.dart';
import '../screens/investment_calculator/compound_interest_calc.dart';
// import '../screens/loans.dart';

Widget buildCalculatorGrid(BuildContext context) {
  final calculators = [
    CalculatorItem(
      icon: Icons.sip,
      title: 'SIP Calculator',
      subtitle: 'Mutual Funds',
      color: Colors.orange.shade400,
      gradient: [Colors.orange.shade400, Colors.orange.shade600],
      route: const SIPCalculator(),
    ),
    CalculatorItem(
      icon: Icons.stacked_line_chart,
      title: 'CAGR Calculator',
      subtitle: 'Compounded Annual Growth Rate',
      color: Colors.amber.shade400,
      gradient: [Colors.amber.shade400, Colors.amber.shade600],
      route: const CAGRCalculator(),
    ),
    CalculatorItem(
      icon: Icons.percent,
      title: 'Compound Interest Calculator',
      subtitle: 'Compound Interest Calculator',
      color: Colors.indigo.shade400,
      gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
      route: const CompoundInterestCalculator(),
    ),
    // CalculatorItem(
    //   icon: Icons.account_balance,
    //   title: 'FD Calculator',
    //   subtitle: 'Fixed Deposit',
    //   color: Colors.teal.shade400,
    //   gradient: [Colors.teal.shade400, Colors.teal.shade600],
    // ),
    // CalculatorItem(
    //   icon: Icons.security,
    //   title: 'Retirement',
    //   subtitle: 'Plan Ahead',
    //   color: Colors.indigo.shade400,
    //   gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
    //   route: const SIPCalculatorApp(),
    // ),
    // CalculatorItem(
    //   icon: Icons.currency_exchange,
    //   title: 'Currency',
    //   subtitle: 'Exchange Rates',
    //   color: Colors.cyan.shade400,
    //   gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
    // ),
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
