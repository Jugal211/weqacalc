import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weqacalc/services/financial_health_service.dart';

void main() {
  group('FinancialHealthScore', () {
    test('Excellent score (>=80) returns green color and star emoji', () {
      final score = FinancialHealthScore(
        score: 85,
        category: 'Excellent',
        strengths: [],
        improvements: [],
        recommendation: 'test',
      );

      expect(
        score.getScoreColor().toARGB32(),
        const Color(0xFF4CAF50).toARGB32(),
      );
      expect(score.getScoreEmoji(), '🌟');
    });

    test('Good score (60-79) returns blue color and thumbs up emoji', () {
      final score = FinancialHealthScore(
        score: 70,
        category: 'Good',
        strengths: [],
        improvements: [],
        recommendation: 'test',
      );

      expect(
        score.getScoreColor().toARGB32(),
        const Color(0xFF2196F3).toARGB32(),
      );
      expect(score.getScoreEmoji(), '👍');
    });

    test('Fair score (40-59) returns amber color and warning emoji', () {
      final score = FinancialHealthScore(
        score: 45,
        category: 'Fair',
        strengths: [],
        improvements: [],
        recommendation: 'test',
      );

      expect(
        score.getScoreColor().toARGB32(),
        const Color(0xFFFFC107).toARGB32(),
      );
      expect(score.getScoreEmoji(), '⚠️');
    });

    test('Poor score (<40) returns red color and error emoji', () {
      final score = FinancialHealthScore(
        score: 25,
        category: 'Needs Work',
        strengths: [],
        improvements: [],
        recommendation: 'test',
      );

      expect(
        score.getScoreColor().toARGB32(),
        const Color(0xFFF44336).toARGB32(),
      );
      expect(score.getScoreEmoji(), '❌');
    });
  });

  group('FinancialHealthScoreService.calculateScore', () {
    test('Excellent savings rate (>=30%) adds strength and 25 points', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 35000,
        investmentAmount: 10000,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 5,
      );

      expect(
        score.strengths.any((s) => s.contains('Excellent savings rate')),
        true,
      );
      expect(score.score, greaterThanOrEqualTo(80));
    });

    test('Good savings rate (20-29%) adds strength and 20 points', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 25000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: false,
        calculatorsUsed: 1,
      );

      expect(score.strengths.any((s) => s.contains('Good savings rate')), true);
    });

    test('Low savings (<10%) adds improvement and 0 points', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 5000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: false,
        calculatorsUsed: 0,
      );

      expect(
        score.improvements.any((i) => i.contains('10-15% savings target')),
        true,
      );
    });

    test('Active investment adds strength and 20 points', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 20000,
        investmentAmount: 50000,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 1,
      );

      expect(
        score.strengths.any((s) => s.contains('actively investing')),
        true,
      );
    });

    test('No investment adds improvement', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 20000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 1,
      );

      expect(
        score.improvements.any((i) => i.contains('SIP or mutual funds')),
        true,
      );
    });

    test('Emergency fund adds strength and 20 points', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 20000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 1,
      );

      expect(score.strengths.any((s) => s.contains('Emergency fund')), true);
    });

    test('No emergency fund adds improvement', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 20000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: false,
        calculatorsUsed: 1,
      );

      expect(
        score.improvements.any((i) => i.contains('6-month emergency fund')),
        true,
      );
    });

    test('High calculator usage (>=5) adds awareness strength', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 20000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 5,
      );

      expect(
        score.strengths.any((s) => s.contains('Strong financial awareness')),
        true,
      );
    });

    test('Low calculator usage adds improvement', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 100000,
        monthlySavings: 20000,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 1,
      );

      expect(
        score.improvements.any((i) => i.contains('more calculators')),
        true,
      );
    });

    test('Score is clamped between 0 and 100', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 1000000,
        monthlySavings: 500000,
        investmentAmount: 500000,
        loanAmount: 0,
        hasEmergencyFund: true,
        calculatorsUsed: 10,
      );

      expect(score.score, lessThanOrEqualTo(100));
      expect(score.score, greaterThanOrEqualTo(0));
    });

    test('Zero income returns 0 savings rate', () {
      final score = FinancialHealthScoreService.calculateScore(
        monthlyIncome: 0,
        monthlySavings: 0,
        investmentAmount: 0,
        loanAmount: 0,
        hasEmergencyFund: false,
        calculatorsUsed: 0,
      );

      expect(score.score, 0);
    });
  });
}
