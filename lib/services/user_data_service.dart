import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to track user financial data and calculator usage
class UserDataService {
  static const String _calculatorUsageKey = 'calculator_usage';
  static const String _monthlyIncomeKey = 'monthly_income';
  static const String _monthlySavingsKey = 'monthly_savings';
  static const String _hasEmergencyFundKey = 'has_emergency_fund';
  static const String _totalDebtKey = 'total_debt';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Calculator usage tracking
  Future<void> trackCalculatorUsage(String calculatorType) async {
    final usage = getCalculatorUsage();
    final updatedUsage = Map<String, int>.from(usage);
    updatedUsage[calculatorType] = (updatedUsage[calculatorType] ?? 0) + 1;
    await _prefs.setString(_calculatorUsageKey, jsonEncode(updatedUsage));
  }

  Map<String, int> getCalculatorUsage() {
    final json = _prefs.getString(_calculatorUsageKey);
    if (json == null) return {};
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  int getTotalCalculatorsUsed() {
    final usage = getCalculatorUsage();
    return usage.keys.length; // Count unique calculators used
  }

  int getTotalCalculations() {
    final usage = getCalculatorUsage();
    return usage.values.fold(0, (sum, count) => sum + count);
  }

  // Financial data
  Future<void> setMonthlyIncome(double income) async {
    await _prefs.setDouble(_monthlyIncomeKey, income);
  }

  double getMonthlyIncome() {
    return _prefs.getDouble(_monthlyIncomeKey) ?? 0;
  }

  Future<void> setMonthlySavings(double savings) async {
    await _prefs.setDouble(_monthlySavingsKey, savings);
  }

  double getMonthlySavings() {
    return _prefs.getDouble(_monthlySavingsKey) ?? 0;
  }

  Future<void> setHasEmergencyFund(bool hasEmergencyFund) async {
    await _prefs.setBool(_hasEmergencyFundKey, hasEmergencyFund);
  }

  bool getHasEmergencyFund() {
    return _prefs.getBool(_hasEmergencyFundKey) ?? false;
  }

  Future<void> setTotalDebt(double debt) async {
    await _prefs.setDouble(_totalDebtKey, debt);
  }

  double getTotalDebt() {
    return _prefs.getDouble(_totalDebtKey) ?? 0;
  }

  // Estimate monthly income based on savings/investment patterns
  double estimateMonthlyIncome({
    double? monthlySavings,
    double? monthlyExpenses,
    double? monthlyEMI,
  }) {
    // Check if user has set income
    final storedIncome = getMonthlyIncome();
    if (storedIncome > 0) {
      return storedIncome;
    }

    // Try to estimate from various sources
    if (monthlySavings != null && monthlySavings > 0) {
      // Assume 20% savings rate
      return monthlySavings / 0.2;
    }

    if (monthlyExpenses != null && monthlyExpenses > 0) {
      // Assume 50% of income goes to expenses
      return monthlyExpenses / 0.5;
    }

    if (monthlyEMI != null && monthlyEMI > 0) {
      // EMI should ideally be 40% or less of income
      return monthlyEMI / 0.4;
    }

    // Default fallback
    return 50000;
  }

  Future<void> reset() async {
    await _prefs.remove(_calculatorUsageKey);
    await _prefs.remove(_monthlyIncomeKey);
    await _prefs.remove(_monthlySavingsKey);
    await _prefs.remove(_hasEmergencyFundKey);
    await _prefs.remove(_totalDebtKey);
  }
}
