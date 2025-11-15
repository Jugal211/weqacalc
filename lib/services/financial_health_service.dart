import 'package:flutter/material.dart';

class FinancialHealthScore {
  final int score; // 0-100
  final String category; // 'Poor', 'Fair', 'Good', 'Excellent'
  final List<String> strengths;
  final List<String> improvements;
  final String recommendation;

  FinancialHealthScore({
    required this.score,
    required this.category,
    required this.strengths,
    required this.improvements,
    required this.recommendation,
  });

  Color getScoreColor() {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFF2196F3); // Blue
    if (score >= 40) return const Color(0xFFFFC107); // Amber
    return const Color(0xFFF44336); // Red
  }

  String getScoreEmoji() {
    if (score >= 80) return '🌟';
    if (score >= 60) return '👍';
    if (score >= 40) return '⚠️';
    return '❌';
  }
}

class FinancialHealthScoreService {
  static FinancialHealthScore calculateScore({
    required double monthlyIncome,
    required double monthlySavings,
    required double investmentAmount,
    required double loanAmount,
    required bool hasEmergencyFund,
    required int calculatorsUsed,
  }) {
    int score = 0;
    final strengths = <String>[];
    final improvements = <String>[];

    // Savings rate (target: 20-30% of income)
    double savingsRate = monthlyIncome > 0
        ? (monthlySavings / monthlyIncome) * 100
        : 0;
    if (savingsRate >= 30) {
      score += 25;
      strengths.add(
        '💰 Excellent savings rate (${savingsRate.toStringAsFixed(0)}%)',
      );
    } else if (savingsRate >= 20) {
      score += 20;
      strengths.add(
        '💰 Good savings rate (${savingsRate.toStringAsFixed(0)}%)',
      );
    } else if (savingsRate >= 10) {
      score += 10;
      improvements.add('📈 Increase savings to 20%+ of income');
    } else {
      improvements.add('📈 Start with a 10-15% savings target');
    }

    // Investment habits
    if (investmentAmount > 0) {
      score += 20;
      strengths.add('📊 You\'re actively investing');
    } else {
      improvements.add('💡 Begin investing in SIP or mutual funds');
    }

    // Debt management
    double debtToIncomeRatio = monthlyIncome > 0
        ? (loanAmount / (monthlyIncome * 12))
        : 0;
    if (debtToIncomeRatio < 3) {
      score += 15;
      strengths.add('✅ Healthy debt-to-income ratio');
    } else if (debtToIncomeRatio < 5) {
      score += 8;
      improvements.add('🎯 Consider accelerating loan repayment');
    } else {
      improvements.add('⚠️ High debt level—prioritize payoff');
    }

    // Emergency fund
    if (hasEmergencyFund) {
      score += 20;
      strengths.add('🛡️ Emergency fund established');
    } else {
      improvements.add('🚨 Build 6-month emergency fund');
    }

    // Financial awareness (based on calculator usage)
    if (calculatorsUsed >= 5) {
      score += 20;
      strengths.add('🧠 Strong financial awareness');
    } else if (calculatorsUsed >= 2) {
      score += 10;
      improvements.add('📚 Explore more calculators for holistic planning');
    } else {
      improvements.add('🔍 Use more calculators to understand your finances');
    }

    // Clamp score
    score = score.clamp(0, 100);

    String category;
    String recommendation;

    if (score >= 80) {
      category = 'Excellent';
      recommendation =
          'You\'re on an excellent financial path! Focus on wealth maximization and retirement planning.';
    } else if (score >= 60) {
      category = 'Good';
      recommendation =
          'You\'re doing well! Fine-tune your strategy with better savings and investment habits.';
    } else if (score >= 40) {
      category = 'Fair';
      recommendation =
          'You\'re on the right track. Increase your savings rate and start investing regularly.';
    } else {
      category = 'Needs Work';
      recommendation =
          'Start with small steps—build an emergency fund and aim for 10% monthly savings.';
    }

    return FinancialHealthScore(
      score: score,
      category: category,
      strengths: strengths,
      improvements: improvements,
      recommendation: recommendation,
    );
  }

  // Factory method for SIP Calculator
  static FinancialHealthScore calculateForSIP({
    required double monthlyInvestment,
    required int timePeriodYears,
    required bool hasRegularInvesting,
    required int calculatorsUsed,
  }) {
    // Convert to standard parameters for scoring
    double monthlySavings = monthlyInvestment;
    double investmentAmount = monthlyInvestment * timePeriodYears * 12;

    return calculateScore(
      monthlyIncome: monthlySavings > 0
          ? (monthlySavings / 0.2)
          : 0, // Assume 20% savings rate
      monthlySavings: monthlySavings,
      investmentAmount: investmentAmount,
      loanAmount: 0,
      hasEmergencyFund: hasRegularInvesting,
      calculatorsUsed: calculatorsUsed,
    );
  }

  // Factory method for EMI Calculator
  static FinancialHealthScore calculateForEMI({
    required double monthlyEMI,
    required double loanAmount,
    required int loanTenureYears,
    required double estimatedMonthlyIncome,
    required int calculatorsUsed,
  }) {
    // EMI ratio: EMI to income
    double emiRatio = estimatedMonthlyIncome > 0
        ? (monthlyEMI / estimatedMonthlyIncome) * 100
        : 0;

    return calculateScore(
      monthlyIncome: estimatedMonthlyIncome,
      monthlySavings: estimatedMonthlyIncome - monthlyEMI,
      investmentAmount: 0,
      loanAmount: loanAmount,
      hasEmergencyFund: emiRatio < 40,
      calculatorsUsed: calculatorsUsed,
    );
  }

  // Factory method for Loan Prepayment Calculator
  static FinancialHealthScore calculateForLoanPrepayment({
    required double monthlyEMI,
    required double extraPayment,
    required double loanAmount,
    required double estimatedMonthlyIncome,
    required int calculatorsUsed,
  }) {
    double totalMonthlyPayment = monthlyEMI + extraPayment;

    // Extra payment shows proactive debt management
    bool isProactiveInDebtPayment = extraPayment > 0;

    return calculateScore(
      monthlyIncome: estimatedMonthlyIncome,
      monthlySavings: estimatedMonthlyIncome - totalMonthlyPayment,
      investmentAmount: 0,
      loanAmount: loanAmount,
      hasEmergencyFund: isProactiveInDebtPayment,
      calculatorsUsed: calculatorsUsed,
    );
  }

  // Factory method for Compound Interest / FD / RD Calculators
  static FinancialHealthScore calculateForFixedInvestments({
    required double monthlyInvestment,
    required int timePeriodYears,
    required double maturityAmount,
    required int calculatorsUsed,
  }) {
    return calculateScore(
      monthlyIncome: monthlyInvestment > 0 ? (monthlyInvestment / 0.15) : 0,
      monthlySavings: monthlyInvestment,
      investmentAmount: maturityAmount,
      loanAmount: 0,
      hasEmergencyFund: true,
      calculatorsUsed: calculatorsUsed,
    );
  }
}
