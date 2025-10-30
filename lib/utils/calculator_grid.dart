import 'package:flutter/material.dart';
import 'package:weqacalc/models/calculator_item.dart';
import 'package:weqacalc/utils/calculator_card.dart';
import '../screens/investment_calculator/sip_calc.dart';
import '../screens/investment_calculator/cagr_calc.dart';
import '../screens/investment_calculator/simple_interest_calc.dart';
import '../screens/investment_calculator/compound_interest_calc.dart';
import '../screens/investment_calculator/fd_calc.dart';
import '../screens/investment_calculator/rd_calc.dart';
import '../screens/investment_calculator/ppf_calc.dart';
import '../screens/investment_calculator/epf_calc.dart';
import '../screens/investment_calculator/ssy_calc.dart';
import '../screens/retirement_calculator/retirement_calc.dart';
import '../screens/retirement_calculator/fire_calc.dart';
import '../screens/loan_calculator/emi_calc.dart';
import '../screens/loan_calculator/home_loan_calc.dart';
import '../screens/loan_calculator/loan_prepay_calc.dart';

List<CalculatorItem> getFilteredCalculators(
  List<CalculatorCategory> categories,
  int selectedIndex,
) {
  final allCalculators = [
    // Loan Calculators
    CalculatorItem(
      title: 'EMI Calculator',
      subtitle: 'Calculate EMIs for all types of loan',
      icon: Icons.trending_up_rounded,
      gradient: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      category: 'Loan',
      route: const EMICalculator(),
    ),
    CalculatorItem(
      title: 'Mortgage',
      subtitle: 'Home Loans',
      icon: Icons.home_rounded,
      gradient: [Color(0xFF2196F3), Color(0xFF1976D2)],
      category: 'Loan',
      route: const HomeLoanCalculator(),
    ),
    CalculatorItem(
      title: 'Loan Prepayment',
      subtitle: 'Techniques to save interest and finish loan faster',
      icon: Icons.auto_fix_high_rounded,
      gradient: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      category: 'Loan',
      route: const LoanPrepaymentCalculator(),
    ),
    // Investment Calculators
    CalculatorItem(
      title: 'SIP Calculator',
      subtitle: 'Mutual Funds',
      icon: Icons.account_balance_wallet_rounded,
      gradient: [Color(0xFFFF9800), Color(0xFFF57C00)],
      category: 'Investment',
      route: const SIPCalculator(),
    ),
    CalculatorItem(
      title: 'CAGR Calculator',
      subtitle: 'Compounded Annual Growth Rate',
      icon: Icons.show_chart_rounded,
      gradient: [Color(0xFFFFC107), Color(0xFFFFA000)],
      category: 'Investment',
      route: const CAGRCalculator(),
    ),
    CalculatorItem(
      title: 'Simple Interest Calculator',
      subtitle: 'Simple Interest Calculator',
      icon: Icons.percent_rounded,
      gradient: [Color(0xFF009688), Color(0xFF00796B)],
      category: 'Investment',
      route: const SimpleInterestCalculator(),
    ),
    CalculatorItem(
      title: 'Compound Interest Calculator',
      subtitle: 'Lumpsum Investments',
      icon: Icons.percent_rounded,
      gradient: [Color(0xFF673AB7), Color(0xFF512DA8)],
      category: 'Investment',
      route: const CompoundInterestCalculator(),
    ),
    CalculatorItem(
      title: 'FD Calculator',
      subtitle: 'Fixed Deposit',
      icon: Icons.savings_rounded,
      gradient: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      category: 'Investment',
      route: const FDCalculator(),
    ),
    CalculatorItem(
      title: 'RD Calculator',
      subtitle: 'Recurring Deposit',
      icon: Icons.savings_rounded,
      gradient: [Color(0xFF795548), Color(0xFF5D4037)],
      category: 'Investment',
      route: const RDCalculator(),
    ),
    CalculatorItem(
      title: 'PPF Calculator',
      subtitle: 'Public Provident Fund',
      icon: Icons.account_balance_rounded,
      gradient: [Color(0xFF3F51B5), Color(0xFF303F9F)],
      category: 'Investment',
      route: const PPFCalculator(),
    ),
    CalculatorItem(
      title: 'EPF Calculator',
      subtitle: 'Employee Provident Fund',
      icon: Icons.business_center_rounded,
      gradient: [Color(0xFF9CCC65), Color(0xFF7CB342)],
      category: 'Investment',
      route: const EPFCalculator(),
    ),
    CalculatorItem(
      title: 'SSY Calculator',
      subtitle: 'Sukanya Samriddhi Yojana',
      icon: Icons.child_care_rounded,
      gradient: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      category: 'Investment',
      route: const SSYCalculator(),
    ),
    // Retirement Calculators
    CalculatorItem(
      title: 'Retirement Planning Calculator',
      subtitle: 'Plan your retirement',
      icon: Icons.elderly_rounded,
      gradient: [Color(0xFF607D8B), Color(0xFF455A64)],
      category: 'Retirement',
      route: const RetirementPlanningCalculator(),
    ),
    CalculatorItem(
      title: 'FIRE Calculator',
      subtitle: '(Financial Independence, Retire Early)',
      icon: Icons.local_fire_department_rounded,
      gradient: [Color(0xFFF44336), Color(0xFFD32F2F)],
      category: 'Retirement',
      route: const FIRECalculator(),
    ),
  ];

  if (selectedIndex == 0) {
    return allCalculators;
  } else {
    final categoryName = categories[selectedIndex].name;
    return allCalculators
        .where((calc) => calc.category == categoryName)
        .toList();
  }
}

Widget buildCalculatorGrid(
  List<CalculatorCategory> categories,
  int selectedIndex,
) {
  final calculators = getFilteredCalculators(categories, selectedIndex);

  return AnimatedSwitcher(
    duration: Duration(milliseconds: 300),
    child: Column(
      key: ValueKey(selectedIndex),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            '${calculators.length} Calculators Available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: calculators.length,
            itemBuilder: (context, index) {
              return buildCalculatorCard(context, calculators[index], index);
            },
          ),
        ),
      ],
    ),
  );
}
